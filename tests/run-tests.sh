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
  for name in brew code mise defaults chflags scutil sudo chsh; do
    # shellcheck disable=SC2016 # expands when the stub runs
    printf '#!/bin/sh\necho "%s $*" >> "$STUB_LOG"\n' "$name" > "$dir/$name"
  done

  cat > "$dir/uname" <<'STUB'
#!/bin/sh
echo "${FAKE_UNAME:-Darwin}"
STUB

  cat > "$dir/starship" <<'STUB'
#!/bin/sh
echo "starship $*" >> "$STUB_LOG"
if [ "$1" = preset ]; then echo "$2" > "$4"; fi
STUB

  # Serves the installers that scripts pipe into a shell, and fakes downloads.
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
  *z.sh*) : > "$HOME/z.sh" ;;
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
    BREW_BIN="$stubs/brew" STUB_LOG="$log" FAKE_REPO="$REPO" "$@" </dev/null
}

new_home() {
  home="$sandbox/home$((++homes))"
  log="$home.log"
  mkdir -p "$home"
  : > "$log"
}

test_flow() {
  echo "flow"

  local sandbox stubs home log homes=0
  sandbox=$(mktemp -d)
  trap 'rm -rf "$sandbox"' RETURN
  stubs="$sandbox/stubs"
  mkdir -p "$stubs"
  make_stubs "$stubs"

  # Full setup on a machine with an existing, unmanaged Git config.
  new_home
  echo "original" > "$home/.gitconfig"
  check "full setup succeeds" in_sandbox bash "$REPO/setup.sh" all
  check "git config linked" links_to "$home/.gitconfig" "$REPO/git/.gitconfig"
  check "existing git config backed up" grep -q original "$home"/.gitconfig.backup.*
  check "VS Code settings linked" links_to "$home/Library/Application Support/Code/User/settings.json" "$REPO/code/settings.json"
  check "zshrc sources zsh.env" has_count "$home/.zshrc" "$REPO/zsh.env" 1
  check "real Homebrew kept out of the sandbox" grep -q "brew shellenv" "$log"
  check "Brewfile installed" grep -q "brew bundle install --no-upgrade --file $REPO/Brewfile" "$log"
  check "Oh My Zsh keeps zshrc" grep -q "omz .*--keep-zshrc" "$log"
  check_not "Oh My Zsh template not written" grep -q "omz template created" "$log"
  check "mise config linked" links_to "$home/.config/mise/config.toml" "$REPO/mise/config.toml"
  check "Node packages installed" grep -q "mise install" "$log"
  check "Ghostty config linked" links_to "$home/.config/ghostty/config" "$REPO/ghostty/config"
  check "tmux config linked" links_to "$home/.tmux.conf" "$REPO/tmux/.tmux.conf"
  check "tmux plugin manager cloned" test -d "$home/.tmux/plugins/tpm"
  check "starship config created" grep -q gruvbox-rainbow "$home/.config/starship.toml"
  check_not "hostname untouched by full setup" grep -q scutil "$log"
  check_not "packages not upgraded by full setup" grep -q "brew upgrade" "$log"

  # Running again changes nothing.
  : > "$log"
  check "second run succeeds" in_sandbox bash "$REPO/setup.sh" all
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
