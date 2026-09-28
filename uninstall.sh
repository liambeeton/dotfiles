#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
echo "Script directory: $DOTFILES_DIR"

. "$DOTFILES_DIR/brew/uninstall.sh"

. "$DOTFILES_DIR/claude/uninstall.sh"

. "$DOTFILES_DIR/codex/uninstall.sh"

. "$DOTFILES_DIR/code/uninstall.sh"

. "$DOTFILES_DIR/git/uninstall.sh"

. "$DOTFILES_DIR/node/uninstall.sh"

. "$DOTFILES_DIR/zsh/uninstall.sh"
