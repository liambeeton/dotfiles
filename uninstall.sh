#!/usr/bin/env bash

# Removes what setup.sh installed, including app data and shell history.
# Usage: ./uninstall.sh                                  remove everything
#        ./uninstall.sh brew|code|git|mise|terminal|zsh  remove one part

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

uninstall_mise() {
  rm -rf ~/.volta
  rm -rf ~/.jenv
  rm -rf ~/.config/mise
  rm -rf ~/.local/share/mise
  rm -rf ~/.local/state/mise
  rm -rf ~/Library/Caches/mise
}

uninstall_terminal() {
  rm -rf ~/.config/ghostty
  rm -f ~/.tmux.conf
  rm -rf ~/.tmux
}

uninstall_zsh() {
  rm -f ~/.zcompdump
  rm -f ~/.zprofile
  rm -f ~/.zsh_history
  rm -f ~/.zshrc.pre-oh-my-zsh
  rm -f ~/.zshrc
  rm -f ~/z.sh
  rm -f ~/.z
  rm -f ~/.config/starship.toml

  rm -rf ~/.config/atuin
  rm -rf ~/.local/share/atuin
  rm -rf ~/Library/Application\ Support/zoxide
  rm -rf ~/.zsh
  rm -rf ~/.zsh_sessions
  rm -rf ~/.oh-my-zsh
}

case "${1:-all}" in
  all)
    uninstall_brew
    uninstall_code
    uninstall_git
    uninstall_mise
    uninstall_terminal
    uninstall_zsh
    ;;
  brew) uninstall_brew ;;
  code) uninstall_code ;;
  git) uninstall_git ;;
  mise) uninstall_mise ;;
  terminal) uninstall_terminal ;;
  zsh) uninstall_zsh ;;
  *)
    echo "Usage: $0 [all|brew|code|git|mise|terminal|zsh]" >&2
    exit 1
    ;;
esac
