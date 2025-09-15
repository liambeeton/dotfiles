#!/bin/zsh

# Exit on first error
set -e

# Remove files
rm ~/.zcompdump
rm ~/.zprofile
rm ~/.zsh_history
rm ~/.zshrc.pre-oh-my-zsh
rm ~/.zshrc
rm ~/z.sh

# Remove folders
rm -rf ~/.zsh
rm -rf ~/.zsh_sessions
rm -rf ~/.oh-my-zsh
