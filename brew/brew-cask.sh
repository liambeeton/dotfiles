#!/bin/zsh

# Exit on first error
set -e

casks=(
  1password
  arq
  brave-browser
  charles
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
  notion
  postman
  protonvpn
  raycast
  rectangle
  slack
  spotify
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
