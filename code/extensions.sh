#!/usr/bin/env bash

set -euo pipefail

extensions=(
  openai.chatgpt
  anthropic.claude-code
  GitHub.github-vscode-theme
  vscode-icons-team.vscode-icons
)

for i in "${extensions[@]}"; do
  code --install-extension "$i"
done
