#!/bin/zsh

# Exit on first error
set -e

packages=(
  awscli
  azure-cli
  difftastic
  direnv
  dive
  dotnet
  eza
  git
  git-delta
  git-lfs
  go
  golangci-lint
  gotestsum
  gnupg
  gradle
  helm
  jenv
  jq
  k6
  kubectl
  minikube
  mkcert
  ollama
  openssl@3
  redis
  ripgrep
  starship
  tfenv
  tgenv
  tree
  uv
  wget
  ykman
)

brew install --force "${packages[@]}"
