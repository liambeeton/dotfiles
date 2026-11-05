#!/usr/bin/env bash

set -euo pipefail

curl https://get.volta.sh | bash

# Use Volta in current shell
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

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
