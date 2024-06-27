#!/bin/zsh

# Exit on first error
set -e

# Modifies the PATH for the current user to include the Volta shim directory
volta setup

# Reload settings after setup
source ~/.zshrc

# Install node and snpm
volta install node
volta install npm

packages=(
  eslint
  http-server
  nodemon
  release-it
  spot
  svgo
  tldr
  vtop
)

npm install -g "${packages[@]}"
