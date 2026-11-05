#!/usr/bin/env bash

set -euo pipefail

CMD=""

if command -v wget >/dev/null 2>&1; then
  CMD="wget --no-check-certificate -O -"
fi

if command -v curl >/dev/null 2>&1; then
  CMD="curl -#L"
fi

if [ -z "$CMD" ]; then
  echo "No curl or wget available. Aborting."
else
  echo "Installing dotfiles"
  mkdir -p "$HOME/.dotfiles" &&
    eval "$CMD https://github.com/liambeeton/dotfiles/tarball/master | tar -xzv -C ~/.dotfiles --strip-components=1 --exclude='{.gitignore}'"
  . "$HOME/.dotfiles/install.sh"
fi
