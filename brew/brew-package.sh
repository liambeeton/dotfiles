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
  dotnet
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
  openssl@3
  pyenv
  pyenv-virtualenv
  redis
  ripgrep
  rustup-init
  starship
  tfenv
  tgenv
  volta
  wget
  ykman
)

brew install --force "${packages[@]}"
