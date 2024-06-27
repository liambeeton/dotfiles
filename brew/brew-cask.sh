#!/bin/zsh

# Exit on first error
set -e

casks=(
  1password
  android-studio
  arq
  azure-data-studio
  bartender
  cloudflare-warp
  discord
  docker
  firefox
  font-hack-nerd-font
  google-chrome
  insomnia
  intellij-idea-ce
  iterm2
  maccy
  #microsoft-office
  ngrok
  notion
  raycast
  rectangle
  signal
  #slack
  spotify
  telegram
  tor-browser
  transmission
  typora
  visual-studio-code
  vlc
  whatsapp
  wireshark
  yubico-authenticator
  zoom
)

brew install --cask --force "${casks[@]}"
