#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
echo "Script directory: $DOTFILES_DIR"

ln -sfv "$DOTFILES_DIR/git/.gitconfig" ~
ln -sfv "$DOTFILES_DIR/git/.gitmessage.txt" ~
ln -sfv "$DOTFILES_DIR/git/.global_gitattributes" ~
ln -sfv "$DOTFILES_DIR/git/.global_gitignore" ~

ln -sfv "$DOTFILES_DIR/code/keybindings.json" ~/Library/Application\ Support/Code/User/keybindings.json
ln -sfv "$DOTFILES_DIR/code/settings.json" ~/Library/Application\ Support/Code/User/settings.json

ln -sfv "$DOTFILES_DIR/zsh/.zshrc" ~

mkdir -p ~/.claude
ln -sfv "$DOTFILES_DIR/claude/settings.json" ~/.claude/settings.json

mkdir -p ~/.codex
ln -sfv "$DOTFILES_DIR/codex/config.toml" ~/.codex/config.toml
