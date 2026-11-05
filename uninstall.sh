#!/usr/bin/env bash

# Removes what setup.sh installed, including app data and shell history.
# Usage: ./uninstall.sh                                  remove everything
#        ./uninstall.sh brew|code|git|node|terminal|zsh  remove one part

set -euo pipefail

uninstall_brew() {
  if command -v brew >/dev/null 2>&1; then
    brew list --cask | xargs brew uninstall --cask --force
    brew cleanup
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
  fi

  sudo rm -rf /opt/homebrew/
}

uninstall_code() {
  rm -rf ~/Library/Preferences/com.microsoft.VSCode.helper.plist
  rm -rf ~/Library/Preferences/com.microsoft.VSCode.plist
  rm -rf ~/Library/Caches/com.microsoft.VSCode
  rm -rf ~/Library/Caches/com.microsoft.VSCode.ShipIt/
  rm -rf ~/Library/Application\ Support/Code/
  rm -rf ~/Library/Saved\ Application\ State/com.microsoft.VSCode.savedState/
  rm -rf ~/.vscode/
}

uninstall_git() {
  rm -f ~/.gitconfig
  rm -f ~/.gitmessage.txt
  rm -f ~/.global_gitattributes
  rm -f ~/.global_gitignore
}

uninstall_node() {
  rm -rf ~/.volta
}

uninstall_terminal() {
  rm -rf ~/.config/ghostty
}

uninstall_zsh() {
  rm -f ~/.zcompdump
  rm -f ~/.zprofile
  rm -f ~/.zsh_history
  rm -f ~/.zshrc.pre-oh-my-zsh
  rm -f ~/.zshrc
  rm -f ~/z.sh

  rm -rf ~/.zsh
  rm -rf ~/.zsh_sessions
  rm -rf ~/.oh-my-zsh
}

case "${1:-all}" in
  all)
    uninstall_brew
    uninstall_code
    uninstall_git
    uninstall_node
    uninstall_terminal
    uninstall_zsh
    ;;
  brew) uninstall_brew ;;
  code) uninstall_code ;;
  git) uninstall_git ;;
  node) uninstall_node ;;
  terminal) uninstall_terminal ;;
  zsh) uninstall_zsh ;;
  *)
    echo "Usage: $0 [all|brew|code|git|node|terminal|zsh]" >&2
    exit 1
    ;;
esac
