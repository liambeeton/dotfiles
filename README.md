# dotfiles

Personal macOS dotfiles and bootstrap scripts. One command sets up a development workstation, and re-running it only does what is missing.

- macOS Finder, screenshot, and Preview defaults
- Homebrew, CLI packages, and GUI casks from a `Brewfile`
- Git configuration, global ignore rules, attributes, and commit template
- VS Code settings, keybindings, and extensions
- Zsh, Oh My Zsh, plugins, aliases, and shell paths
- Node.js through Volta plus common global npm packages

These scripts are personal and intentionally opinionated. Review them before running on a machine you do not want fully reconfigured.

Requires macOS on Apple Silicon (Homebrew paths assume `/opt/homebrew`) and admin access.

## Install

### One-click

```sh
curl -fsSL https://raw.githubusercontent.com/liambeeton/dotfiles/main/install.sh | bash
```

This installs Homebrew if needed, clones the repo to `~/.dotfiles`, and runs the full setup. It only works while the repo is public; otherwise clone it first.

### From a clone

```sh
git clone https://github.com/liambeeton/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
```

### Interactive

```sh
./setup.sh
```

Choose a full setup, tools only, or configuration only from a menu.

## Common Commands

`make help` lists every task. Each one calls a step in `setup.sh` or `uninstall.sh`.

| Target | Purpose |
| --- | --- |
| `make install` | Full setup, pulling the latest changes first |
| `make sync` | Refresh symlinks and `~/.zshrc` without installing anything |
| `make check` | Verify shell script headers and syntax |
| `make macos-defaults` | Apply Finder, screenshot, Preview, and Library visibility defaults |
| `make macos-hostname` | Set the computer name (not part of the full setup) |
| `make brew` | Install Homebrew, update it, and upgrade packages |
| `make brew-bundle` | Install what is missing from the `Brewfile` |
| `make git-install` | Link Git dotfiles |
| `make code-install` | Link VS Code settings and keybindings |
| `make code-extensions` | Install VS Code extensions |
| `make zsh` | Install Oh My Zsh, plugins, and `z.sh` |
| `make node` | Install Volta, Node.js, and global npm packages |

The full setup does not upgrade packages that are already installed. Run `make brew` for that.

## Layout

```text
.
|-- Brewfile      CLI packages, GUI apps, and fonts
|-- install.sh    One-click installer: fetches the repo, then runs setup.sh
|-- setup.sh      Every setup step, as functions, plus the menu
|-- uninstall.sh  Every removal step
|-- zsh.env       Shared Zsh configuration, sourced by ~/.zshrc
|-- code/         VS Code settings and keybindings
`-- git/          Git config, ignore rules, attributes, commit template
```

## Customizing

- **Packages:** edit `Brewfile`.
- **VS Code extensions, npm packages, computer name:** edit the values at the top of `setup.sh`.
- **Shell config for every machine:** edit `zsh.env`.
- **Shell config for one machine:** edit `~/.zshrc`. It is not tracked, and it only needs to keep the line that sources `zsh.env`. Installers that append to it no longer dirty the repo.

Git and VS Code files are symlinked, so edits take effect immediately. An existing file is copied to `<file>.backup.<timestamp>` before it is replaced or edited.

## Uninstall

```sh
make uninstall
```

This removes Homebrew and casks, VS Code user data, Git dotfiles, Volta, Zsh files, Oh My Zsh, and shell history. Read `uninstall.sh` first: these commands permanently delete files from `$HOME` and application support directories. Use `make brew-uninstall`, `code-uninstall`, `git-uninstall`, `node-uninstall`, or `zsh-uninstall` to remove one part.
