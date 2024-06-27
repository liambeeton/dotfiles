#!/bin/zsh

# Exit on first error
set -e

# Run this script from anywhere
export DOTFILES_DIR
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Uninstall homebrew"

# Uninstall brew packages and casks
. "$DOTFILES_DIR/brew/uninstall.sh"

echo "Uninstall visual studio code"

# Uninstall visual studio code
. "$DOTFILES_DIR/code/uninstall.sh"

echo "Uninstall git"

# Uninstall git
. "$DOTFILES_DIR/git/uninstall.sh"

echo "Uninstall node"

# Uninstall node
. "$DOTFILES_DIR/node/uninstall.sh"

echo "Uninstall zsh"

# Uninstall oh my zsh
. "$DOTFILES_DIR/zsh/uninstall.sh"

echo "Lastly, housekeeping!"

# Housekeeping
. "$DOTFILES_DIR/housekeeping.sh"
