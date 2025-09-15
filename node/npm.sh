#!/bin/zsh

# Exit on first error
set -e

# Install volta
curl https://get.volta.sh | bash

# Reload settings
source ~/.zshenv

# Install node
volta install node

packages=(
  eslint
  http-server
  nodemon
  pnpm
  release-it
  spot
  svgo
  tldr
  typescript
  vtop
  yarn
)

npm install -g "${packages[@]}"
