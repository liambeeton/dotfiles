#!/usr/bin/env bash

# Sets up this machine from the repo. Every step is safe to re-run.
# Usage: ./setup.sh          choose from a menu
#        ./setup.sh <step>   run one step (./setup.sh help lists them)

set -euo pipefail

DOTFILES_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
COMPUTER_NAME="Aesoteric"
BREW_BIN="${BREW_BIN:-/opt/homebrew/bin/brew}"
PAM_DIR="${PAM_DIR:-/etc/pam.d}"
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"

vscode_extensions=(
  GitHub.github-vscode-theme
  vscode-icons-team.vscode-icons
)

# Colors only in a terminal, so that saved logs stay readable.
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  RED='\033[0;31m'
  CYAN='\033[0;36m'
  NC='\033[0m'
else
  GREEN=''
  YELLOW=''
  RED=''
  CYAN=''
  NC=''
fi

print_section() { echo -e "\n${CYAN}=== $1 ===${NC}"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_info() { echo -e "${YELLOW}→${NC} $1"; }
print_error() { echo -e "${RED}✗ $1${NC}" >&2; }

# Prints a follow-up for the user, and repeats it in the summary at the end.
add_note() {
  print_info "$1"
  if [[ -n "${SETUP_NOTES_FILE:-}" ]]; then
    echo "$1" >> "$SETUP_NOTES_FILE"
  fi
}

# Runs one step, and on failure records it and moves on. The subshell is what lets
# set -e stop the step at its first failed command; inside an if or a || it would
# be ignored. It also means a step cannot change this shell's variables, which is
# why notes go through a file and load_homebrew_env runs separately.
run_step() {
  local name="$1" status=0
  shift

  set +e
  (
    set -e
    "$@"
  )
  status=$?
  set -e

  # Ctrl-C stops the whole run, not just this step.
  if [[ "$status" -eq 130 ]]; then
    exit 130
  fi
  if [[ "$status" -ne 0 ]]; then
    print_error "$name failed, continuing with the next step"
    FAILED_STEPS="$FAILED_STEPS$name"$'\n'
  fi
}

# Runs the given steps, then prints the summary. Fails if any step failed.
run_with_summary() {
  FAILED_STEPS=""
  SETUP_NOTES_FILE=$(mktemp)
  trap 'rm -f "$SETUP_NOTES_FILE"' EXIT

  "$@"

  print_section "Summary"
  if [[ -s "$SETUP_NOTES_FILE" ]]; then
    echo "Next steps:"
    sed 's/^/  - /' "$SETUP_NOTES_FILE"
  fi
  echo "Restart your terminal or run: exec zsh"

  if [[ -n "$FAILED_STEPS" ]]; then
    echo ""
    print_error "These steps failed. Their errors are in the output above:"
    printf '%s' "$FAILED_STEPS" | sed 's/^/  - /' >&2
    echo "Fix the cause and run this again. It is safe to re-run." >&2
    exit 1
  fi
  print_success "All steps finished"
}

check_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    print_error "This script is designed for macOS only."
    exit 1
  fi
}

# Copies a file aside before it is replaced or edited. Backups are timestamped
# so that repeated runs can never overwrite an earlier one.
backup_file() {
  local backup
  backup="$1.backup.$(date +%Y%m%d%H%M%S)"
  cp -p "$1" "$backup"
  print_info "Backed up $1 to $backup"
}

link_file() {
  local src="$1" dest="$2"

  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    print_success "$dest already linked"
    return
  fi
  if [[ -f "$dest" && ! -L "$dest" ]]; then
    backup_file "$dest"
  fi
  ln -sf "$src" "$dest"
  print_success "Linked $dest"
}

# Every symlink this repo manages, as <file in the repo>|<where it is linked>.
# Used by both setup and doctor.
print_links() {
  cat <<EOF
git/.gitconfig|$HOME/.gitconfig
git/.gitmessage.txt|$HOME/.gitmessage.txt
git/.global_gitattributes|$HOME/.global_gitattributes
git/.global_gitignore|$HOME/.global_gitignore
code/keybindings.json|$VSCODE_USER_DIR/keybindings.json
code/settings.json|$VSCODE_USER_DIR/settings.json
ghostty/config|$HOME/.config/ghostty/config
tmux/.tmux.conf|$HOME/.tmux.conf
mise/config.toml|$HOME/.config/mise/config.toml
EOF
}

# Links the files from one folder of the repo.
link_folder() {
  local src dest
  while IFS='|' read -r src dest; do
    mkdir -p "$(dirname "$dest")"
    link_file "$DOTFILES_DIR/$src" "$dest"
  done < <(print_links | grep "^$1/")
}

setup_macos_defaults() {
  print_section "macOS defaults"

  # Take screenshots as jpg (usually smaller size) and not png
  defaults write com.apple.screencapture type jpg

  # Save screenshots to their own folder instead of the Desktop
  mkdir -p ~/Screenshots
  defaults write com.apple.screencapture location ~/Screenshots

  # Do not open previous previewed files (e.g. PDFs) when opening a new one
  defaults write com.apple.Preview ApplePersistenceIgnoreState YES

  # Show Library folder
  chflags nohidden ~/Library

  # Show hidden files
  defaults write com.apple.finder AppleShowAllFiles -bool true

  # Show all file extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # Show path bar
  defaults write com.apple.finder ShowPathbar -bool true

  # Show status bar
  defaults write com.apple.finder ShowStatusBar -bool true

  # Fast key repeat, and no accent popup when holding a key (helps in Vim)
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

  # Stop smart quotes and dashes from mangling pasted code
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

  # No .DS_Store files on network shares or USB drives
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

  # Auto-hide the Dock
  defaults write com.apple.dock autohide -bool true

  # killall returns an error if any of these is not running, such as over SSH.
  killall Finder Dock SystemUIServer || true

  print_success "macOS defaults applied"
  add_note "Log out and back in if the keyboard settings changed"
}

# sudo_local survives macOS updates, unlike edits to /etc/pam.d/sudo. An existing
# one is left alone, because it may hold other settings.
setup_touch_id_sudo() {
  if [[ -f "$PAM_DIR/sudo_local" ]]; then
    print_success "$PAM_DIR/sudo_local already exists, leaving it alone"
  elif [[ -f "$PAM_DIR/sudo_local.template" ]]; then
    sed 's/^#auth/auth/' "$PAM_DIR/sudo_local.template" | sudo tee "$PAM_DIR/sudo_local" >/dev/null
    print_success "Touch ID enabled for sudo"
  else
    print_info "This macOS has no sudo_local template, skipping Touch ID for sudo"
  fi
}

# Only checks FileVault. Enabling it prints the recovery key, which must not get
# lost in the middle of the install output.
check_filevault() {
  if fdesetup status | grep -q "FileVault is On"; then
    print_success "FileVault is on"
  else
    add_note "FileVault does not appear to be on. To enable it, run this and save the recovery key it prints: sudo fdesetup enable"
  fi
}

setup_macos_security() {
  print_section "macOS security"

  setup_touch_id_sudo

  sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
  print_success "Firewall on"

  check_filevault
}

set_hostname() {
  print_section "Hostname"

  # Set computer name (as done via System Preferences → Sharing)
  sudo scutil --set ComputerName "$COMPUTER_NAME"
  sudo scutil --set HostName "$COMPUTER_NAME"
  sudo scutil --set LocalHostName "$COMPUTER_NAME"
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPUTER_NAME"

  print_success "Computer name set to $COMPUTER_NAME"
}

load_homebrew_env() {
  if [[ -x "$BREW_BIN" ]]; then
    eval "$("$BREW_BIN" shellenv)"
  fi
}

install_homebrew() {
  print_section "Homebrew"

  if command -v brew >/dev/null 2>&1 || [[ -x "$BREW_BIN" ]]; then
    print_success "Homebrew already installed"
  else
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  load_homebrew_env
  if ! command -v brew >/dev/null 2>&1; then
    print_error "Homebrew not found at $BREW_BIN after installing."
    exit 1
  fi

  if ! grep -qs 'brew shellenv' "$HOME/.zprofile"; then
    # shellcheck disable=SC2016 # the line must expand when the shell starts
    printf '\neval "$(%s shellenv)"\n' "$BREW_BIN" >> "$HOME/.zprofile"
    print_success "Added Homebrew to ~/.zprofile"
  fi
}

update_homebrew() {
  print_info "Updating Homebrew and upgrading packages..."
  brew update
  brew upgrade
}

install_tools() {
  print_section "Brewfile"
  brew bundle install --no-upgrade --file "$DOTFILES_DIR/Brewfile"
  print_success "Brewfile packages installed"

  # tealdeer has no pages until its cache is downloaded once.
  tldr --update || print_info "Could not update tldr pages. Run: tldr --update"
}

setup_git() {
  print_section "Git"
  link_folder git
}

setup_vscode() {
  print_section "VS Code settings"
  link_folder code
}

install_vscode_extensions() {
  print_section "VS Code extensions"

  local extension
  for extension in "${vscode_extensions[@]}"; do
    code --install-extension "$extension"
  done
}

# ~/.zshrc is a local file that sources the tracked zsh.env, so anything an
# installer appends to it stays out of the repo.
setup_zsh() {
  print_section "Zsh"

  local zshrc="$HOME/.zshrc"

  # Earlier versions of this repo symlinked ~/.zshrc into it. Drop the link so
  # that the source line below is not written into a tracked file.
  if [[ -L "$zshrc" && "$(readlink "$zshrc")" == "$DOTFILES_DIR"/* ]]; then
    rm "$zshrc"
    print_info "Removed old ~/.zshrc symlink"
  fi

  if grep -qsF "$DOTFILES_DIR/zsh.env" "$zshrc"; then
    print_success "$zshrc already sources zsh.env"
    return
  fi

  if [[ -f "$zshrc" ]]; then
    backup_file "$zshrc"
  fi
  printf 'source "%s/zsh.env"\n' "$DOTFILES_DIR" >> "$zshrc"
  print_success "Added source line to ~/.zshrc"
}

install_oh_my_zsh() {
  # The Oh My Zsh installer writes its own ~/.zshrc unless one already exists
  # and --keep-zshrc is set. Its template would load Oh My Zsh a second time.
  setup_zsh

  print_section "Oh My Zsh"

  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    print_success "Oh My Zsh already installed"
  else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
    print_success "Oh My Zsh installed"
  fi

  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}" plugin
  for plugin in zsh-autosuggestions zsh-completions zsh-syntax-highlighting; do
    if [[ -d "$custom/plugins/$plugin" ]]; then
      print_success "$plugin already installed"
    else
      git clone "https://github.com/zsh-users/$plugin" "$custom/plugins/$plugin"
    fi
  done
}

setup_ghostty() {
  print_section "Ghostty"
  link_folder ghostty
}

setup_tmux() {
  print_section "tmux"
  link_folder tmux
}

install_tmux_plugin_manager() {
  print_section "tmux plugin manager"

  if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
    print_success "TPM already installed"
  else
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi

  if [[ ! -d "$HOME/.tmux/plugins/tmux-resurrect" ]]; then
    add_note "Press prefix + I inside tmux to install its plugins"
  fi
}

# Generated rather than tracked, and never overwrites a config you already have.
setup_starship() {
  print_section "Starship"

  local config="$HOME/.config/starship.toml"
  if [[ -f "$config" ]]; then
    print_success "$config already exists"
  elif command -v starship >/dev/null 2>&1; then
    mkdir -p "$HOME/.config"
    starship preset gruvbox-rainbow -o "$config"
    print_success "Created $config"
  else
    print_info "Starship is not installed yet, skipping its config"
  fi
}

setup_mise() {
  print_section "mise"
  link_folder mise
}

install_mise_tools() {
  setup_mise
  mise install --yes
  print_success "Tools from mise/config.toml installed"
}

set_zsh_default() {
  print_section "Default shell"

  if [[ "${SHELL##*/}" == "zsh" ]]; then
    print_success "Zsh is already the default shell"
  else
    chsh -s /bin/zsh
    print_success "Default shell set to Zsh"
  fi
}

setup_tools() {
  run_step "Homebrew" install_homebrew
  load_homebrew_env
  run_step "Brewfile packages" install_tools
  run_step "VS Code extensions" install_vscode_extensions
  run_step "Oh My Zsh" install_oh_my_zsh
  run_step "tmux plugin manager" install_tmux_plugin_manager
  run_step "mise tools" install_mise_tools
}

setup_configs() {
  run_step "Git config" setup_git
  run_step "VS Code config" setup_vscode
  run_step "Zsh config" setup_zsh
  run_step "Ghostty config" setup_ghostty
  run_step "tmux config" setup_tmux
  run_step "Starship config" setup_starship
  run_step "mise config" setup_mise
}

setup_everything() {
  run_step "macOS defaults" setup_macos_defaults
  run_step "macOS security" setup_macos_security
  setup_tools
  setup_configs
  run_step "Default shell" set_zsh_default
}

setup_all() {
  run_with_summary setup_everything
}

report_problem() {
  print_error "$1"
  DOCTOR_PROBLEMS=$((DOCTOR_PROBLEMS + 1))
}

doctor_brew() {
  print_section "Brewfile"

  if ! command -v brew >/dev/null 2>&1; then
    report_problem "Homebrew is not installed. Fix: make install"
    return
  fi

  # Auto-update would change Homebrew, and doctor only reads.
  if HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --verbose --no-upgrade --file "$DOTFILES_DIR/Brewfile"; then
    print_success "Everything in the Brewfile is installed"
  else
    report_problem "Brewfile packages are missing. Fix: make brew-bundle"
  fi
}

doctor_mise() {
  print_section "mise"

  if ! command -v mise >/dev/null 2>&1; then
    report_problem "mise is not installed. Fix: make brew-bundle"
    return
  fi

  # Run from $HOME, so that the version files of the project you are in do not
  # affect the result.
  local output problems
  if output=$(cd "$HOME" && mise doctor 2>&1); then
    print_success "mise reports no problems"
  else
    # The full report is long, so show only its list of problems if it has one.
    problems=$(printf '%s\n' "$output" | sed -n '/problems* found:/,$p')
    printf '%s\n' "${problems:-$output}"
    report_problem "mise reports problems. Fix: make mise, and restart your terminal if it says mise is not activated"
  fi
}

doctor_links() {
  print_section "Config files"

  local src dest
  while IFS='|' read -r src dest; do
    if [[ -e "$dest" && -L "$dest" && "$(readlink "$dest")" == "$DOTFILES_DIR/$src" ]]; then
      print_success "$dest"
    else
      report_problem "$dest is not linked to $src. Fix: make sync"
    fi
  done < <(print_links)

  if grep -qsF "$DOTFILES_DIR/zsh.env" "$HOME/.zshrc"; then
    print_success "$HOME/.zshrc sources zsh.env"
  else
    report_problem "$HOME/.zshrc does not source zsh.env. Fix: make sync"
  fi
}

# Reports what has drifted from this repo. Only reads, so it fixes nothing.
run_doctor() {
  DOCTOR_PROBLEMS=0

  load_homebrew_env
  doctor_brew
  doctor_mise
  doctor_links

  print_section "Doctor"
  if [[ "$DOCTOR_PROBLEMS" -gt 0 ]]; then
    print_error "Found $DOCTOR_PROBLEMS problem(s), listed above with how to fix them"
    exit 1
  fi
  print_success "No problems found"
}

prompt_menu() {
  echo "Select what to run:"
  echo "1) Full setup (install all tools + configure)"
  echo "2) Install tools only"
  echo "3) Configure only (refresh symlinks and ~/.zshrc)"
  echo "4) Quit"
  echo ""

  local choice
  read -r -p "Enter choice [1-4]: " choice
  case "$choice" in
    1) setup_all ;;
    2) run_with_summary setup_tools ;;
    3) run_with_summary setup_configs ;;
    4) exit 0 ;;
    *)
      print_error "Invalid choice."
      exit 1
      ;;
  esac
}

print_usage() {
  cat <<'EOF'
Usage: ./setup.sh [step]

  all              Full setup
  tools            Install tools only
  config           Refresh symlinks and ~/.zshrc
  doctor           Report what has drifted from this repo, changing nothing
  macos-defaults   Apply macOS defaults
  macos-security   Enable Touch ID for sudo and the firewall, check FileVault
  macos-hostname   Set macOS computer name
  brew             Install Homebrew, update it, and upgrade packages
  brew-bundle      Install what is missing from the Brewfile
  git              Link Git dotfiles
  code             Link VS Code settings and keybindings
  code-extensions  Install VS Code extensions
  ghostty          Link Ghostty config
  tmux             Link tmux config and install its plugin manager
  zsh              Install Oh My Zsh and plugins
  mise             Install Java, Node.js, Terraform, Terragrunt, and npm packages

With no step, shows a menu.
EOF
}

main() {
  check_macos

  case "${1:-}" in
    "") prompt_menu ;;
    all) setup_all ;;
    tools) run_with_summary setup_tools ;;
    config) run_with_summary setup_configs ;;
    doctor) run_doctor ;;
    macos-defaults) setup_macos_defaults ;;
    macos-security) setup_macos_security ;;
    macos-hostname) set_hostname ;;
    brew)
      install_homebrew
      update_homebrew
      ;;
    brew-bundle)
      install_homebrew
      install_tools
      ;;
    git) setup_git ;;
    code) setup_vscode ;;
    code-extensions) install_vscode_extensions ;;
    ghostty) setup_ghostty ;;
    tmux)
      setup_tmux
      install_tmux_plugin_manager
      ;;
    zsh) install_oh_my_zsh ;;
    mise) install_mise_tools ;;
    help | -h | --help) print_usage ;;
    *)
      print_usage >&2
      exit 1
      ;;
  esac
}

# Only run main if executed directly, so install.sh can source these functions.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
