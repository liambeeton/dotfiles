#!/bin/zsh

# Exit on first error
set -e

# Uninstall casks
brew list --cask | xargs brew uninstall --cask --force

# Homebrew cleanup
brew cleanup

# Uninstall brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# Remove folders
sudo rm -rf /opt/homebrew/
