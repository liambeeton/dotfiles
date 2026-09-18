#!/usr/bin/env bash

set -euo pipefail

packages=(
  awscli
  azure-cli
  difftastic
  direnv
  dive
  dotnet
  eza
  flyway
  gh
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
  maven
  minikube
  mkcert
  ollama
  opencode
  openssl@3
  ripgrep
  starship
  tailscale
  tfenv
  tgenv
  tree
  uv
  wget
  ykman
)

brew install --force "${packages[@]}"
