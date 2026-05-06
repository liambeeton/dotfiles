#!/usr/bin/env bash

set -euo pipefail

casks=(
  1password
  arq
  bartender
  brave-browser
  charles
  claude
  claude-code
  cloudflare-warp
  discord
  docker-desktop
  firefox
  font-fira-code
  font-hack-nerd-font
  font-jetbrains-mono
  font-source-code-pro
  foobar2000
  google-chrome
  imageoptim
  insomnia
  iterm2
  jetbrains-toolbox
  little-snitch
  maccy
  ngrok
  obsidian
  postman
  protonvpn
  raycast
  rectangle
  slack
  soapui
  spotify
  tailscale-app
  typora
  visual-studio-code
  vlc
  whatsapp
  wireshark-app
  yubico-authenticator
  zoom
)

brew install --cask --force "${casks[@]}"
