#!/bin/zsh

# Exit on first error
set -e

extensions=(
  burkeholland.simple-react-snippets
  DavidAnson.vscode-markdownlint
  dbaeumer.vscode-eslint
  dsznajder.es7-react-js-snippets
  esbenp.prettier-vscode
  fredwangwang.vscode-hcl-format
  GitHub.github-vscode-theme
  golang.Go
  HashiCorp.HCL
  HashiCorp.terraform
  ms-azuretools.vscode-docker
  ms-dotnettools.csdevkit
  planbcoding.vscode-react-refactor
  redhat.vscode-yaml
  streetsidesoftware.code-spell-checker
  tombonnike.vscode-status-bar-format-toggle
  vscode-icons-team.vscode-icons
  yoavbls.pretty-ts-errors
  sirmspencer.vscode-autohide
  unifiedjs.vscode-mdx
  ms-vscode.vscode-typescript-next
  anthropic.claude-code
)

for i in ${extensions[@]}; do
  code --install-extension $i
done
