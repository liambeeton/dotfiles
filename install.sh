#!/bin/zsh

# Exit on first error
set -e

# Run this script from anywhere
export DOTFILES_DIR
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Update dotfiles
[ -d "$DOTFILES_DIR/.git" ] && git --work-tree="$DOTFILES_DIR" --git-dir="$DOTFILES_DIR/.git" pull origin main

# Set macos defaults
. "$DOTFILES_DIR/macos/defaults.sh"

# Install brew
. "$DOTFILES_DIR/brew/brew.sh"

# Install brew packages
. "$DOTFILES_DIR/brew/brew-package.sh"

# Set git symlinks
ln -sfv "$DOTFILES_DIR/git/.gitconfig" ~
ln -sfv "$DOTFILES_DIR/git/.gitmessage.txt" ~
ln -sfv "$DOTFILES_DIR/git/.global_gitattributes" ~
ln -sfv "$DOTFILES_DIR/git/.global_gitignore" ~

# Install brew casks
. "$DOTFILES_DIR/brew/brew-cask.sh"

# Install visual studio code extensions
. "$DOTFILES_DIR/code/extensions.sh"

# Set code symlinks
ln -sfv "$DOTFILES_DIR/code/keybindings.json" ~/Library/Application\ Support/Code/User/keybindings.json
ln -sfv "$DOTFILES_DIR/code/settings.json" ~/Library/Application\ Support/Code/User/settings.json

# Install zsh
. "$DOTFILES_DIR/zsh/zsh.sh"

# Set zsh symlinks
ln -sfv "$DOTFILES_DIR/zsh/.zshrc" ~

# Install node and npm packages
. "$DOTFILES_DIR/node/npm.sh"
