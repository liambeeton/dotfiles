#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
echo "Script directory: $DOTFILES_DIR"

[ -d "$DOTFILES_DIR/.git" ] && git --work-tree="$DOTFILES_DIR" --git-dir="$DOTFILES_DIR/.git" pull origin main

. "$DOTFILES_DIR/macos/defaults.sh"

. "$DOTFILES_DIR/brew/brew.sh"

. "$DOTFILES_DIR/brew/brew-package.sh"

ln -sfv "$DOTFILES_DIR/git/.gitconfig" ~
ln -sfv "$DOTFILES_DIR/git/.gitmessage.txt" ~
ln -sfv "$DOTFILES_DIR/git/.global_gitattributes" ~
ln -sfv "$DOTFILES_DIR/git/.global_gitignore" ~

. "$DOTFILES_DIR/brew/brew-cask.sh"

. "$DOTFILES_DIR/code/extensions.sh"

ln -sfv "$DOTFILES_DIR/code/keybindings.json" ~/Library/Application\ Support/Code/User/keybindings.json
ln -sfv "$DOTFILES_DIR/code/settings.json" ~/Library/Application\ Support/Code/User/settings.json

. "$DOTFILES_DIR/zsh/zsh.sh"

ln -sfv "$DOTFILES_DIR/zsh/.zshrc" ~

. "$DOTFILES_DIR/node/npm.sh"
