#!/usr/bin/env bash

# Sets up this machine from the repo. Every step is safe to re-run.
# Usage: ./setup.sh          choose from a menu
#        ./setup.sh <step>   run one step (./setup.sh help lists them)

set -euo pipefail

DOTFILES_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
COMPUTER_NAME="Aesoteric"
BREW_BIN="${BREW_BIN:-/opt/homebrew/bin/brew}"
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"

vscode_extensions=(
  GitHub.github-vscode-theme
  vscode-icons-team.vscode-icons
)

npm_packages=(
  eslint
  http-server
  nodemon
  pnpm
  release-it
  spot
  svgo
  tldr
  typescript
  vtop
  yarn
)

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

print_section() { echo -e "\n${CYAN}=== $1 ===${NC}"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_info() { echo -e "${YELLOW}→${NC} $1"; }
print_error() { echo -e "${RED}✗ $1${NC}" >&2; }

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

setup_macos_defaults() {
  print_section "macOS defaults"

  # Take screenshots as jpg (usually smaller size) and not png
  defaults write com.apple.screencapture type jpg

  # Do not open previous previewed files (e.g. PDFs) when opening a new one
  defaults write com.apple.Preview ApplePersistenceIgnoreState YES

  # Show Library folder
  chflags nohidden ~/Library

  # Show hidden files
  defaults write com.apple.finder AppleShowAllFiles YES

  # Show path bar
  defaults write com.apple.finder ShowPathbar -bool true

  # Show status bar
  defaults write com.apple.finder ShowStatusBar -bool true

  print_success "macOS defaults applied"
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

install_homebrew() {
  print_section "Homebrew"

  if command -v brew >/dev/null 2>&1 || [[ -x "$BREW_BIN" ]]; then
    print_success "Homebrew already installed"
  else
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if [[ -x "$BREW_BIN" ]]; then
    eval "$("$BREW_BIN" shellenv)"
  fi
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
}

setup_git() {
  print_section "Git"

  local file
  for file in .gitconfig .gitmessage.txt .global_gitattributes .global_gitignore; do
    link_file "$DOTFILES_DIR/git/$file" "$HOME/$file"
  done
}

setup_vscode() {
  print_section "VS Code settings"

  mkdir -p "$VSCODE_USER_DIR"
  link_file "$DOTFILES_DIR/code/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
  link_file "$DOTFILES_DIR/code/settings.json" "$VSCODE_USER_DIR/settings.json"
}

install_vscode_extensions() {
  print_section "VS Code extensions"

  local extension
  for extension in "${vscode_extensions[@]}"; do
    code --install-extension "$extension"
  done
}

setup_zsh() {
  print_section "Zsh"
  link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
}

install_oh_my_zsh() {
  # The Oh My Zsh installer writes its own ~/.zshrc unless one already exists
  # and --keep-zshrc is set, so link ours first.
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

  if [[ -f "$HOME/z.sh" ]]; then
    print_success "z.sh already installed"
  else
    curl -fsSL https://raw.githubusercontent.com/rupa/z/master/z.sh -o "$HOME/z.sh"
    print_success "z.sh installed"
  fi
}

install_node() {
  print_section "Node.js"

  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"

  if [[ -x "$VOLTA_HOME/bin/volta" ]]; then
    print_success "Volta already installed"
  else
    curl https://get.volta.sh | bash
  fi

  volta install node
  npm install -g "${npm_packages[@]}"
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
  install_homebrew
  install_tools
  install_vscode_extensions
  install_oh_my_zsh
  install_node
}

setup_configs() {
  setup_git
  setup_vscode
  setup_zsh
}

setup_all() {
  setup_macos_defaults
  setup_tools
  setup_configs
  set_zsh_default
  print_section "Setup complete"
  echo "Restart your terminal or run: exec zsh"
}

prompt_menu() {
  echo "Select what to run:"
  echo "1) Full setup (install all tools + configure)"
  echo "2) Install tools only"
  echo "3) Configure only (refresh symlinks)"
  echo "4) Quit"
  echo ""

  local choice
  read -r -p "Enter choice [1-4]: " choice
  case "$choice" in
    1) setup_all ;;
    2) setup_tools ;;
    3) setup_configs ;;
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
  config           Refresh symlinks
  macos-defaults   Apply macOS defaults
  macos-hostname   Set macOS computer name
  brew             Install Homebrew, update it, and upgrade packages
  brew-bundle      Install what is missing from the Brewfile
  git              Link Git dotfiles
  code             Link VS Code settings and keybindings
  code-extensions  Install VS Code extensions
  zsh              Install Oh My Zsh and plugins
  node             Install Volta, Node.js, and global packages

With no step, shows a menu.
EOF
}

main() {
  check_macos

  case "${1:-}" in
    "") prompt_menu ;;
    all) setup_all ;;
    tools) setup_tools ;;
    config) setup_configs ;;
    macos-defaults) setup_macos_defaults ;;
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
    zsh) install_oh_my_zsh ;;
    node) install_node ;;
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
