#!/usr/bin/env bash

# Checks the scripts without touching this machine: every flow runs against a
# throwaway HOME, with anything that installs or changes the system stubbed out.
# Usage: tests/run-tests.sh [static|flow|all]

set -euo pipefail

REPO=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
failures=0

pass() { echo "  ok    $1"; }
fail() {
  echo "  FAIL  $1"
  failures=$((failures + 1))
}
check() {
  local name="$1"
  shift
  if "$@" >/dev/null 2>&1; then pass "$name"; else fail "$name"; fi
}
check_not() {
  local name="$1"
  shift
  if "$@" >/dev/null 2>&1; then fail "$name"; else pass "$name"; fi
}
has_count() { [[ "$(grep -cF -- "$2" "$1" 2>/dev/null || true)" == "$3" ]]; }
links_to() { [[ -L "$1" && "$(readlink "$1")" == "$2" ]]; }

test_static() {
  echo "static"

  local script
  while IFS= read -r script; do
    check "$script: shebang" test "$(sed -n 1p "$REPO/$script")" = '#!/usr/bin/env bash'
    check "$script: strict mode" grep -qx 'set -euo pipefail' "$REPO/$script"
    check "$script: syntax" bash -n "$REPO/$script"
  done < <(cd "$REPO" && find . -type f -name '*.sh' -not -path './.git/*' | sed 's|^\./||' | sort)

  if command -v shellcheck >/dev/null 2>&1; then
    check "shellcheck" shellcheck -x "$REPO/install.sh" "$REPO/setup.sh" "$REPO/uninstall.sh" "$REPO/tests/run-tests.sh"
  fi
  if command -v zsh >/dev/null 2>&1; then
    check "zsh.env: syntax" zsh -n "$REPO/zsh.env"
  fi

  check_not "Brewfile: only brew and cask lines" grep -vE '^(#.*|(brew|cask) "[^"]+")?$' "$REPO/Brewfile"
  check_not "Brewfile: no duplicates" bash -c "grep -E '^(brew|cask) ' '$REPO/Brewfile' | sort | uniq -d | grep ."
}

# Stubs log their arguments to $STUB_LOG and do nothing else.
make_stubs() {
  local dir="$1" name
  for name in code tldr fzf atuin zoxide direnv defaults chflags scutil chsh; do
    # shellcheck disable=SC2016 # expands when the stub runs
    printf '#!/bin/sh\necho "%s $*" >> "$STUB_LOG"\n' "$name" > "$dir/$name"
  done

  cat > "$dir/uname" <<'STUB'
#!/bin/sh
echo "${FAKE_UNAME:-Darwin}"
STUB

  # Like the real one, shellenv puts brew on PATH. FAKE_BREW_STATUS fails brew bundle.
  cat > "$dir/brew" <<'STUB'
#!/bin/sh
echo "brew $*" >> "$STUB_LOG"
case "$1" in
  shellenv) echo "export PATH=\"$(dirname "$0"):\$PATH\"" ;;
  bundle)
    echo "HOMEBREW_NO_AUTO_UPDATE=${HOMEBREW_NO_AUTO_UPDATE:-unset}" >> "$STUB_LOG"
    if [ "${FAKE_BREW_STATUS:-0}" != 0 ]; then echo "Cask ghostty needs to be installed"; fi
    exit "${FAKE_BREW_STATUS:-0}"
    ;;
esac
STUB

  # FAKE_MISE_STATUS makes doctor report a problem, after the long report it prints.
  cat > "$dir/mise" <<'STUB'
#!/bin/sh
echo "mise $*" >> "$STUB_LOG"
if [ "$1" = doctor ]; then
  echo "mise ran in $PWD" >> "$STUB_LOG"
  if [ "${FAKE_MISE_STATUS:-0}" != 0 ]; then
    printf 'long report\n1 problem found:\n\n1. tool npm:eslint is not installed\n'
    exit "$FAKE_MISE_STATUS"
  fi
fi
STUB

  # Runs tee for real, so tests can check what would be written.
  cat > "$dir/sudo" <<'STUB'
#!/bin/sh
echo "sudo $*" >> "$STUB_LOG"
if [ "$1" = tee ]; then cat > "$2"; fi
STUB

  cat > "$dir/fdesetup" <<'STUB'
#!/bin/sh
echo "fdesetup $*" >> "$STUB_LOG"
echo "${FAKE_FILEVAULT:-FileVault is On.}"
STUB

  # Fails like the real one does when a process it was given is not running.
  cat > "$dir/killall" <<'STUB'
#!/bin/sh
echo "killall $*" >> "$STUB_LOG"
exit 1
STUB

  cat > "$dir/starship" <<'STUB'
#!/bin/sh
echo "starship $*" >> "$STUB_LOG"
if [ "$1" = preset ]; then echo "$2" > "$4"; fi
STUB

  # Serves the installers that scripts pipe into a shell.
  cat > "$dir/curl" <<'STUB'
#!/bin/sh
echo "curl $*" >> "$STUB_LOG"
case "$*" in
  *ohmyzsh*)
    cat <<'SCRIPT'
echo "omz $*" >> "$STUB_LOG"
[ -f "$HOME/.zshrc" ] || echo "omz template created" >> "$STUB_LOG"
mkdir -p "$HOME/.oh-my-zsh/custom/plugins"
SCRIPT
    ;;
esac
STUB

  cat > "$dir/git" <<'STUB'
#!/bin/sh
echo "git $*" >> "$STUB_LOG"
if [ "$1" = clone ]; then
  case "$2" in
    *liambeeton*) cp -R "$FAKE_REPO" "$3" ;;
    *) mkdir -p "$3" ;;
  esac
fi
STUB

  chmod +x "$dir"/*
}

# Runs a command with HOME and PATH pointed at the sandbox. BREW_BIN keeps a real
# Homebrew out: its shellenv would put the real tools ahead of the stubs on PATH.
in_sandbox() {
  env HOME="$home" PATH="$stubs:$(dirname "$(command -v bash)"):/usr/bin:/bin" SHELL=/bin/zsh \
    BREW_BIN="$stubs/brew" PAM_DIR="$home/pam.d" STUB_LOG="$log" FAKE_REPO="$REPO" "$@" </dev/null
}

# True if the first text appears in the stub log before the second.
in_sandbox_order() {
  local first second
  first=$(grep -nF -- "$1" "$log" | head -n 1 | cut -d: -f1)
  second=$(grep -nF -- "$2" "$log" | head -n 1 | cut -d: -f1)
  [[ -n "$first" && -n "$second" && "$first" -lt "$second" ]]
}

# Runs a command in the sandbox, keeping its status in $status and output in $out.
capture() {
  out="$home.out"
  status=0
  in_sandbox "$@" > "$out" 2>&1 || status=$?
}

# True if the text appears in the summary of the last captured run.
summary_has() {
  sed -n '/=== Summary/,$p' "$out" | grep -qF -- "$1"
}

# Prints every path under the sandbox HOME with its type, target, size, and time.
snapshot_home() {
  find "$home" -exec ls -ld {} + | sort
}

# Prints a variable as zsh.env leaves it.
zsh_value() {
  in_sandbox env HOMEBREW_PREFIX=/fake zsh -c "source '$REPO/zsh.env'; print -r -- \$$1" 2>/dev/null
}

new_home() {
  home="$sandbox/home$((++homes))"
  log="$home.log"
  mkdir -p "$home/pam.d"
  printf '# uncomment to enable Touch ID\n#auth       sufficient     pam_tid.so\n' > "$home/pam.d/sudo_local.template"
  : > "$log"
}

test_flow() {
  echo "flow"

  local sandbox stubs nobrew bare before home log out status homes=0
  sandbox=$(mktemp -d)
  trap 'rm -rf "$sandbox"' RETURN
  stubs="$sandbox/stubs"
  mkdir -p "$stubs"
  make_stubs "$stubs"

  # Full setup on a machine with an existing, unmanaged Git config.
  new_home
  echo "original" > "$home/.gitconfig"
  check "full setup succeeds" in_sandbox bash "$REPO/setup.sh" all
  check "key repeat set" grep -q "defaults write NSGlobalDomain KeyRepeat -int 2" "$log"
  check "screenshot folder created" test -d "$home/Screenshots"
  check "screenshot location set" grep -q "com.apple.screencapture location $home/Screenshots" "$log"
  check "Finder and Dock restarted" grep -q "killall Finder Dock SystemUIServer" "$log"
  check "Touch ID enabled for sudo" grep -qE '^auth +sufficient +pam_tid.so' "$home/pam.d/sudo_local"
  check "firewall turned on" grep -q "socketfilterfw --setglobalstate on" "$log"
  check "FileVault checked" grep -q "fdesetup status" "$log"
  check_not "FileVault never enabled" grep -q "fdesetup enable" "$log"
  check "git config linked" links_to "$home/.gitconfig" "$REPO/git/.gitconfig"
  check "existing git config backed up" grep -q original "$home"/.gitconfig.backup.*
  check "VS Code settings linked" links_to "$home/Library/Application Support/Code/User/settings.json" "$REPO/code/settings.json"
  check "zshrc sources zsh.env" has_count "$home/.zshrc" "$REPO/zsh.env" 1
  check "real Homebrew kept out of the sandbox" grep -q "brew shellenv" "$log"
  check "Brewfile installed" grep -q "brew bundle install --no-upgrade --file $REPO/Brewfile" "$log"
  check "Oh My Zsh keeps zshrc" grep -q "omz .*--keep-zshrc" "$log"
  check_not "Oh My Zsh template not written" grep -q "omz template created" "$log"
  check "mise config linked" links_to "$home/.config/mise/config.toml" "$REPO/mise/config.toml"
  check "mise tools installed" grep -q "mise install" "$log"
  check "Ghostty config linked" links_to "$home/.config/ghostty/config" "$REPO/ghostty/config"
  check "tmux config linked" links_to "$home/.tmux.conf" "$REPO/tmux/.tmux.conf"
  check "tmux plugin manager cloned" test -d "$home/.tmux/plugins/tpm"
  check "starship config created" grep -q gruvbox-rainbow "$home/.config/starship.toml"
  check "tldr pages downloaded" grep -q "tldr --update" "$log"
  check_not "hostname untouched by full setup" grep -q scutil "$log"
  check_not "packages not upgraded by full setup" grep -q "brew upgrade" "$log"

  # Running again changes nothing.
  : > "$log"
  check "second run succeeds" in_sandbox bash "$REPO/setup.sh" all
  check_not "sudo_local not rewritten" grep -q "sudo tee" "$log"
  check "zshrc not duplicated" has_count "$home/.zshrc" "$REPO/zsh.env" 1
  check "zprofile not duplicated" has_count "$home/.zprofile" "brew shellenv" 1
  check "no second backup" test "$(find "$home" -maxdepth 1 -name '*.backup.*' | wc -l)" -eq 1
  check_not "nothing re-cloned" grep -q "git clone" "$log"
  check_not "Oh My Zsh not reinstalled" grep -q "^omz " "$log"
  check "starship config left alone" has_count "$log" "starship preset" 0

  # Uninstall removes it all, and can run twice.
  check "uninstall succeeds" in_sandbox bash "$REPO/uninstall.sh"
  check "uninstall removes Homebrew" grep -q "sudo rm -rf /opt/homebrew/" "$log"
  check_not "uninstall removes zshrc" test -e "$home/.zshrc"
  check_not "uninstall removes git config" test -e "$home/.gitconfig"
  check_not "uninstall removes Oh My Zsh" test -e "$home/.oh-my-zsh"
  check_not "uninstall removes mise config" test -e "$home/.config/mise"
  check_not "uninstall removes tmux config" test -e "$home/.tmux.conf"
  check_not "uninstall removes Ghostty config" test -e "$home/.config/ghostty"
  check "uninstall can re-run" in_sandbox bash "$REPO/uninstall.sh"

  # ~/.zshrc as earlier versions of this repo left it: a symlink into the repo.
  new_home
  ln -s "$REPO/zsh/.zshrc" "$home/.zshrc"
  check "config succeeds over old symlink" in_sandbox bash "$REPO/setup.sh" config
  check_not "old zshrc symlink replaced" test -L "$home/.zshrc"
  check "zshrc sources zsh.env after migration" has_count "$home/.zshrc" "$REPO/zsh.env" 1

  # Touch ID leaves an existing sudo_local alone, and copes with no template.
  new_home
  echo "custom" > "$home/pam.d/sudo_local"
  check "security step succeeds" in_sandbox bash "$REPO/setup.sh" macos-security
  check "sudo_local kept" grep -qx custom "$home/pam.d/sudo_local"
  new_home
  rm "$home/pam.d/sudo_local.template"
  check "security step succeeds without template" in_sandbox bash "$REPO/setup.sh" macos-security
  check_not "no sudo_local without template" test -e "$home/pam.d/sudo_local"

  # FileVault being off warns with the command, and does not stop the setup.
  new_home
  check "FileVault off warns" bash -c '"$@" 2>&1 | grep -q "sudo fdesetup enable"' _ \
    env HOME="$home" PATH="$stubs:$(dirname "$(command -v bash)"):/usr/bin:/bin" PAM_DIR="$home/pam.d" STUB_LOG="$log" \
    FAKE_FILEVAULT="FileVault is Off." bash "$REPO/setup.sh" macos-security
  check "FileVault off does not stop setup" in_sandbox env FAKE_FILEVAULT="FileVault is Off." bash "$REPO/setup.sh" macos-security
  check_not "FileVault not enabled when off" grep -q "fdesetup enable" "$log"

  # An existing starship config is kept, and config-only runs install nothing.
  new_home
  mkdir -p "$home/.config"
  echo "mine" > "$home/.config/starship.toml"
  check "config succeeds with starship config" in_sandbox bash "$REPO/setup.sh" config
  check "starship config kept" grep -q mine "$home/.config/starship.toml"
  check_not "config-only runs no installs" grep -qE "brew bundle|mise install|git clone" "$log"

  # An existing real ~/.zshrc keeps its contents.
  new_home
  echo "export KEEP_ME=1" > "$home/.zshrc"
  check "config succeeds over real zshrc" in_sandbox bash "$REPO/setup.sh" config
  check "zshrc contents kept" grep -q KEEP_ME "$home/.zshrc"
  check "zshrc gains source line" has_count "$home/.zshrc" "$REPO/zsh.env" 1
  check "zshrc backed up" grep -q KEEP_ME "$home"/.zshrc.backup.*

  # curl | bash on a fresh machine, from a directory that is not the repo.
  new_home
  check "piped install succeeds" in_sandbox bash -c "cd '$sandbox' && cat '$REPO/install.sh' | bash"
  check "piped install clones" grep -q "git clone https://github.com/liambeeton/dotfiles.git $home/.dotfiles" "$log"
  check "piped install links from clone" links_to "$home/.gitconfig" "$home/.dotfiles/git/.gitconfig"

  # ./install.sh from a checkout uses that checkout.
  new_home
  check "local install succeeds" in_sandbox bash "$REPO/install.sh"
  check_not "local install does not clone the repo" grep -q "git clone .*liambeeton" "$log"
  check "local install links from checkout" links_to "$home/.gitconfig" "$REPO/git/.gitconfig"

  # A successful run ends with a summary of what is left to do.
  new_home
  capture env FAKE_FILEVAULT="FileVault is Off." bash "$REPO/setup.sh" all
  check "notes do not fail the run" test "$status" -eq 0
  check "summary says all finished" summary_has "All steps finished"
  check "summary has FileVault warning" summary_has "sudo fdesetup enable"
  check "summary has logout note" summary_has "Log out and back in"
  check "summary has tmux note" summary_has "prefix + I"
  check "summary has restart note" summary_has "exec zsh"
  mkdir -p "$home/tmp" "$home/.tmux/plugins/tmux-resurrect"
  capture env TMPDIR="$home/tmp" bash "$REPO/setup.sh" all
  check "notes file cleaned up" test -z "$(ls -A "$home/tmp")"
  check_not "tmux note gone once plugins are installed" summary_has "prefix + I"
  check_not "FileVault note gone when on" summary_has "sudo fdesetup enable"

  # A failed step stops at the failed command, and the other steps still run.
  new_home
  capture env FAKE_BREW_STATUS=1 bash "$REPO/setup.sh" all
  check "failed step fails the run" test "$status" -eq 1
  check "summary names failed step" summary_has "Brewfile packages"
  check_not "summary does not claim success" summary_has "All steps finished"
  check_not "failed step stops at failed command" grep -q "tldr --update" "$log"
  check "steps after failure still run" grep -q "mise install" "$log"
  check "git config linked after failure" links_to "$home/.gitconfig" "$REPO/git/.gitconfig"
  check "zshrc set up after failure" has_count "$home/.zshrc" "$REPO/zsh.env" 1
  check "summary still has notes after failure" summary_has "Log out and back in"

  # Ctrl-C stops the run instead of moving on to the next step.
  new_home
  capture env FAKE_BREW_STATUS=130 bash "$REPO/setup.sh" all
  check "ctrl-c exits 130" test "$status" -eq 130
  check_not "ctrl-c runs no later steps" grep -q "mise install" "$log"

  # A piped install reports a failed step the same way.
  new_home
  capture env FAKE_BREW_STATUS=1 bash -c "cd '$sandbox' && cat '$REPO/install.sh' | bash"
  check "piped install fails the run" test "$status" -eq 1
  check "piped install links after failure" links_to "$home/.gitconfig" "$home/.dotfiles/git/.gitconfig"

  # A single step has no summary and stops on failure.
  new_home
  capture env FAKE_BREW_STATUS=1 bash "$REPO/setup.sh" brew-bundle
  check_not "single step fails without summary" test "$status" -eq 0
  check_not "single step prints no summary" summary_has "exec zsh"

  # tools and config report too.
  new_home
  capture bash "$REPO/setup.sh" config
  check "config prints summary" summary_has "All steps finished"
  capture env FAKE_BREW_STATUS=1 bash "$REPO/setup.sh" tools
  check "tools reports failure" summary_has "Brewfile packages"

  # A new install only finds brew through BREW_BIN, and later steps still need it.
  new_home
  nobrew="$sandbox/nobrew"
  cp -R "$stubs" "$nobrew"
  rm "$nobrew/brew"
  capture env PATH="$nobrew:/usr/bin:/bin" "$(command -v bash)" "$REPO/setup.sh" tools
  check "brew found after install" test "$status" -eq 0
  check "Brewfile installed with brew from BREW_BIN" grep -q "brew bundle install" "$log"

  # doctor passes after a full setup, which also proves setup made every link.
  new_home
  check "setup before doctor" in_sandbox bash "$REPO/setup.sh" all
  before=$(snapshot_home)
  : > "$log"
  capture bash -c "cd '$sandbox' && bash '$REPO/setup.sh' doctor"
  check "healthy doctor passes" test "$status" -eq 0
  check "doctor runs mise from HOME" grep -q "mise ran in $home\$" "$log"
  check "doctor says no problems" grep -q "No problems found" "$out"
  check "doctor checks Brewfile" grep -q "brew bundle check --verbose --no-upgrade --file $REPO/Brewfile" "$log"
  check "doctor turns off auto-update" grep -q "HOMEBREW_NO_AUTO_UPDATE=1" "$log"
  check "doctor runs mise doctor" grep -q "mise doctor" "$log"
  check "healthy doctor changes nothing" test "$before" = "$(snapshot_home)"
  check_not "healthy doctor installs nothing" grep -qE "bundle install|mise install|sudo|git clone" "$log"

  # doctor reports every kind of drift together, with its fix, and fixes none of it.
  rm -f "$home/.gitconfig" "$home/.tmux.conf"
  echo "real file" > "$home/.tmux.conf"
  ln -sfn /nonexistent "$home/.config/mise/config.toml"
  : > "$home/elsewhere"
  ln -sfn "$home/elsewhere" "$home/.config/ghostty/config"
  echo "# no source line" > "$home/.zshrc"
  before=$(snapshot_home)
  : > "$log"
  capture env FAKE_BREW_STATUS=1 FAKE_MISE_STATUS=1 bash "$REPO/setup.sh" doctor
  check "drifted doctor fails" test "$status" -eq 1
  check "doctor counts problems" grep -q "Found 7 problem" "$out"
  check "doctor lists missing packages" grep -q "Cask ghostty needs to be installed" "$out"
  check "doctor gives Brewfile fix" grep -q "Fix: make brew-bundle" "$out"
  check "doctor shows mise problem" grep -q "tool npm:eslint is not installed" "$out"
  check_not "doctor hides long mise report" grep -q "long report" "$out"
  check "doctor gives mise fix" grep -q "Fix: make mise" "$out"
  check "doctor finds missing link" grep -q "$home/.gitconfig is not linked" "$out"
  check "doctor finds real file" grep -q "$home/.tmux.conf is not linked" "$out"
  check "doctor finds broken link" grep -q "$home/.config/mise/config.toml is not linked" "$out"
  check "doctor finds wrong link" grep -q "$home/.config/ghostty/config is not linked" "$out"
  check "doctor finds zshrc without source" grep -q "$home/.zshrc does not source" "$out"
  check "doctor gives link fix" grep -q "Fix: make sync" "$out"
  check "drifted doctor changes nothing" test "$before" = "$(snapshot_home)"

  # make sync repairs what doctor found.
  check "sync after drift" in_sandbox bash "$REPO/setup.sh" config
  capture bash "$REPO/setup.sh" doctor
  check "doctor passes after sync" test "$status" -eq 0

  # doctor notices a link whose file is gone from the repo.
  new_home
  cp -R "$REPO" "$sandbox/repo-copy"
  check "config from repo copy" in_sandbox bash "$sandbox/repo-copy/setup.sh" config
  rm "$sandbox/repo-copy/tmux/.tmux.conf"
  capture bash "$sandbox/repo-copy/setup.sh" doctor
  check "doctor finds file gone from repo" grep -q "$home/.tmux.conf is not linked" "$out"

  # doctor copes with no tools installed at all.
  new_home
  bare="$sandbox/bare"
  mkdir -p "$bare"
  cp "$stubs/uname" "$bare/uname"
  capture env PATH="$bare:/usr/bin:/bin" BREW_BIN=/nonexistent "$(command -v bash)" "$REPO/setup.sh" doctor
  check "doctor fails with no tools" test "$status" -eq 1
  check "doctor reports no Homebrew" grep -q "Homebrew is not installed" "$out"
  check "doctor reports no mise" grep -q "mise is not installed" "$out"
  check "doctor still checks links with no tools" grep -q "$home/.gitconfig is not linked" "$out"

  # zsh.env loads cleanly, with the tools set up in the right order.
  if command -v zsh >/dev/null 2>&1; then
    new_home
    mkdir -p "$home/.oh-my-zsh"
    : > "$home/.oh-my-zsh/oh-my-zsh.sh"
    check "zsh.env loads without errors" test -z "$(in_sandbox zsh -c "source '$REPO/zsh.env'" 2>&1)"
    check_not "zsh.env does not call brew" grep -q "^brew " "$log"
    check "atuin set up after fzf" in_sandbox_order "fzf --zsh" "atuin init"
    check "starship set up last" test "$(tail -n 1 "$log")" = "starship init zsh"
    check_not "z.sh no longer loaded" grep -q 'z\.sh' "$REPO/zsh.env"

    mkdir -p "$home/.cargo"
    echo "export CARGO_LOADED=yes" > "$home/.cargo/env"
    check "ANDROID_HOME expands" test "$(zsh_value ANDROID_HOME)" = "$home/Library/Android/sdk"
    check "DOTNET_ROOT is Homebrew's" test "$(zsh_value DOTNET_ROOT)" = "/fake/opt/dotnet/libexec"
    check "GOROOT is Homebrew's" test "$(zsh_value GOROOT)" = "/fake/opt/go/libexec"
    check "PNPM_HOME follows HOME" test "$(zsh_value PNPM_HOME)" = "$home/Library/pnpm"
    check "cargo env sourced" test "$(zsh_value CARGO_LOADED)" = "yes"
    check_not "cargo env file not on PATH" bash -c "test -n \"\$1\" && case \"\$1\" in *.cargo/env*) exit 0 ;; *) exit 1 ;; esac" _ "$(zsh_value PATH)"
    check "default Homebrew prefix" test "$(in_sandbox env -u HOMEBREW_PREFIX zsh -c "source '$REPO/zsh.env'; print -r -- \$GOROOT" 2>/dev/null)" = "/opt/homebrew/opt/go/libexec"
  fi

  # Entry points.
  new_home
  check "menu quits" in_sandbox bash -c "echo 4 | bash '$REPO/setup.sh'"
  check_not "menu rejects bad choice" in_sandbox bash -c "echo 9 | bash '$REPO/setup.sh'"
  check_not "unknown step fails" in_sandbox bash "$REPO/setup.sh" nope
  check_not "non-macOS refused" in_sandbox env FAKE_UNAME=Linux bash "$REPO/setup.sh" config
  check_not "non-macOS refused by install" in_sandbox env FAKE_UNAME=Linux bash "$REPO/install.sh"
  check "hostname step" in_sandbox bash "$REPO/setup.sh" macos-hostname
  check "hostname applied" grep -q "sudo scutil --set ComputerName Aesoteric" "$log"
  check "brew step upgrades" in_sandbox bash "$REPO/setup.sh" brew
  check "brew upgrade ran" grep -q "brew upgrade" "$log"
  : > "$log"
  check "mise step" in_sandbox bash "$REPO/setup.sh" mise
  check "mise step installs" grep -q "mise install" "$log"
}

case "${1:-all}" in
  static) test_static ;;
  flow) test_flow ;;
  all)
    test_static
    test_flow
    ;;
  *)
    echo "Usage: $0 [static|flow|all]" >&2
    exit 1
    ;;
esac

if ((failures > 0)); then
  echo "$failures failed"
  exit 1
fi
echo "all passed"
