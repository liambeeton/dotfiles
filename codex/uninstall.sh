#!/usr/bin/env bash

set -euo pipefail

CODEX_DOTFILES_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)

if [[ -L "$HOME/.codex/config.toml" && "$(readlink "$HOME/.codex/config.toml")" == "$CODEX_DOTFILES_DIR/codex/config.toml" ]]; then
  rm "$HOME/.codex/config.toml"
fi
