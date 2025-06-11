#!/bin/zsh

# Exit on first error
set -e

packages=(
  awscli
  azure-cli
  commitizen
  difftastic
  direnv
  dive
  eza
  git
  git-delta
  git-lfs
  go
  golangci-lint
  gotestsum
  gnupg
  graphicsmagick
  hashcat
  helm
  jenv
  jq
  k6
  kubectl
  minikube
  mkcert
  nmap
  ollama
  openssl@3
  redis
  ripgrep
  rustup-init
  starship
  tfenv
  tgenv
  uv
  volta
  wget
  ykman
)

brew install --force "${packages[@]}"
