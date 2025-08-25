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
  maccy
  ngrok
  notion
  postman
  protonvpn
  raycast
  rectangle
  sequel-ace
  slack
  spotify
  tor-browser
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
