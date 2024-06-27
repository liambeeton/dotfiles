#!/bin/zsh

# Exit on first error
set -e

# Unattended install of oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install some plugins manually
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting

# Install z command
wget https://raw.githubusercontent.com/rupa/z/master/z.sh -O ~/z.sh
