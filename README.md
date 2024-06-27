# .files

Welcome to my dotfiles repository! This repository contains my personal configuration files for various tools and applications that I use on my system. Feel free to explore, use, and adapt them to your own needs.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Included Files](#included-files)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgements](#acknowledgements)

## Overview

Dotfiles are plain text configuration files on Unix-y systems for things like shells, editors, version control systems, and more. This repository is a collection of my personal dotfiles to set up a new system or synchronize settings across multiple systems.

## On a fresh install of macOS

```bash
sudo softwareupdate -i -a
xcode-select --install
softwareupdate --install-rosetta --agree-to-license
```

## Installation

To get started with my dotfiles, you can clone this repository and run the installation script. Here’s how you can do it:

```bash
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles
./install.sh
```

Make sure to back up any existing configuration files before running the installation script, as it may overwrite them.

## Usage

After installing, you can start using the configured tools and applications with my settings. Below are some examples of how to use them:

### Shell (zsh)

To use the zsh configuration, make sure zsh is installed and set as the default shell:

```bash
chsh -s $(which zsh)
```

### Vim

Open Vim to use the included Vim configuration:

```bash
vim
```

### Git

My git configuration includes useful aliases and settings. Use git as usual:

```bash
git status
```

## Configuration

Feel free to customize the configurations to suit your preferences. Each configuration file is well-commented to explain what each setting does. You can modify the files directly in this repository or copy them to your home directory.

## Included Files

Here are some of the key files included in this repository:

- `.zshrc` - Configuration for zsh
- `.vimrc` - Configuration for Vim
- `.gitconfig` - Configuration for Git
- `.tmux.conf` - Configuration for tmux
- `.bashrc` - Configuration for bash (if you use bash)
- `.aliases` - Custom command aliases

## Contributing

If you have suggestions or improvements, feel free to open an issue or submit a pull request. Contributions are welcome!

## License

This repository is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Acknowledgements

Thanks to all the open-source contributors whose work inspired these configurations. Special thanks to [@myshov](https://github.com/myshov/dotfiles), [@julie-ng](https://github.com/julie-ng/dotfiles), and the [unofficial guide to dotfiles](https://dotfiles.github.io) for their valuable resources and guides.
