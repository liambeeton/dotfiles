#!/bin/zsh

# Exit on first error
set -e

casks=(
  1password
  android-studio
  arq
  bartender
  charles
  cloudflare-warp
  discord
  docker
  firefox
  font-hack-nerd-font
  google-chrome
  insomnia
  iterm2
  jetbrains-toolbox
  maccy
  ngrok
  notion
  postman
  raycast
  rectangle
  signal
  slack
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
