#!/bin/zsh

# Exit on first error
set -e

casks=(
  1password
  android-studio
  arq
  bartender
  charles
  claude
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
  insomnia
  iterm2
  jetbrains-toolbox
  knockknock
  maccy
  native-access
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
  wireshark-app
  xact
  yubico-authenticator
  zoom
)

brew install --cask --force "${casks[@]}"
