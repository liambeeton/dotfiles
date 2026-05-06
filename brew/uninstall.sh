#!/usr/bin/env bash

set -euo pipefail

brew list --cask | xargs brew uninstall --cask --force

brew cleanup

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

sudo rm -rf /opt/homebrew/
