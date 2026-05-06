# dotfiles

Personal macOS dotfiles and bootstrap scripts.

This repo sets up a development workstation with:

- macOS Finder, screenshot, and Preview defaults
- Homebrew, CLI packages, and GUI casks
- Git configuration, global ignore rules, attributes, and commit template
- VS Code settings, keybindings, and extensions
- Zsh, Oh My Zsh, plugins, aliases, and shell paths
- Node.js through Volta plus common global npm packages

## Requirements

- macOS
- Bash
- Git
- `curl` or `wget`
- Admin access for Homebrew, macOS defaults, and hostname changes

These scripts are personal and intentionally opinionated. Review them before running on a machine you do not want fully reconfigured.

## Install

Clone to `~/.dotfiles` and run the full installer:

```sh
git clone https://github.com/liambeeton/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
```

The full install runs:

1. `macos/defaults.sh`
2. `brew/brew.sh`
3. `brew/brew-package.sh`
4. Git dotfile symlinks
5. `brew/brew-cask.sh`
6. `code/extensions.sh`
7. VS Code settings and keybindings symlinks
8. `zsh/zsh.sh`
9. `.zshrc` symlink
10. `node/npm.sh`

## Common Commands

```sh
make help
make install
make uninstall
make check
./sync.sh
```

`make help` lists every available task. Use targeted tasks when you only want one part of the setup:

| Target | Purpose |
| --- | --- |
| `make macos-defaults` | Apply Finder, screenshot, Preview, and Library visibility defaults |
| `make macos-hostname` | Set macOS computer names from `macos/hostname.sh` |
| `make brew` | Install and update Homebrew |
| `make brew-packages` | Install CLI packages from `brew/brew-package.sh` |
| `make brew-casks` | Install GUI apps and fonts from `brew/brew-cask.sh` |
| `make code-install` | Link VS Code settings and keybindings |
| `make code-extensions` | Install VS Code extensions |
| `make node` | Install Volta, Node.js, and global npm packages |
| `make zsh` | Install Oh My Zsh, plugins, and `z.sh` |
| `make git-uninstall` | Remove linked Git dotfiles from `$HOME` |

## Sync Existing Files

Refresh symlinks without reinstalling packages:

```sh
./sync.sh
```

This links:

- Git config files into `$HOME`
- VS Code settings into `~/Library/Application Support/Code/User`
- Zsh config into `$HOME`

## Layout

```text
.
|-- brew/              Homebrew installer, package list, cask list, uninstall script
|-- code/              VS Code settings, keybindings, extensions, install/uninstall scripts
|-- git/               Git config, ignore rules, attributes, commit template
|-- macos/             macOS defaults and hostname scripts
|-- node/              Volta, Node.js, npm global packages
|-- zsh/               Oh My Zsh setup, plugins, .zshrc, uninstall script
|-- install.sh         Full local installer
|-- remote-install.sh  Bootstrap installer for fresh machines
|-- sync.sh            Symlink refresh script
`-- uninstall.sh       Full uninstall script
```

## Notes

- `install.sh` pulls `origin main` when the repo already has a `.git` directory.
- Homebrew setup assumes Apple Silicon paths under `/opt/homebrew`.
- `macos/hostname.sh` sets the computer name to `Aesoteric`.
- `remote-install.sh` currently downloads the GitHub `master` tarball. Update that script if the remote branch should be `main`.
- `make check` currently expects scripts to use `#!/bin/bash`, while repo scripts use `#!/usr/bin/env bash`.

## Uninstall

```sh
make uninstall
```

The uninstall path removes Homebrew/casks, VS Code user files, Git dotfiles, Volta, Zsh files, Oh My Zsh, and related shell state. Read each `*/uninstall.sh` first because these commands delete files from `$HOME` and application support directories.
