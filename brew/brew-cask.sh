#!/bin/zsh

# Exit on first error
set -e

casks=(
  1password
  bartender
  charles
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
  little-snitch@5
  maccy
  ngrok
  protonvpn
  raycast
  rectangle
  typora
  visual-studio-code
  vlc
  xact
  yubico-authenticator
)

brew install --cask --force "${casks[@]}"
