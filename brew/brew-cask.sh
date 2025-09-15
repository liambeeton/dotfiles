#!/bin/zsh

# Exit on first error
set -e

casks=(
  1password
  charles
  docker-desktop
  firefox
  focusrite-control-2
  font-fira-code
  font-hack-nerd-font
  font-jetbrains-mono
  font-source-code-pro
  foobar2000
  google-chrome
  insomnia
  iterm2
  jetbrains-toolbox
  little-snitch
  native-access
  protonvpn
  typora
  visual-studio-code
  vlc
  xact
  yubico-authenticator
)

brew install --cask --force "${casks[@]}"
