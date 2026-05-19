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
  anomalyco/tap/opencode
  openjdk@11
  openjdk@17
  openjdk@21
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
