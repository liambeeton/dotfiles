# dotfiles

Personal macOS dotfiles and bootstrap scripts. One command sets up a development workstation, and re-running it only does what is missing.

- macOS Finder, screenshot, and Preview defaults
- Homebrew, CLI packages, and GUI casks from a `Brewfile`
- Git configuration, global ignore rules, attributes, and commit template
- VS Code settings, keybindings, and extensions
- Zsh, Oh My Zsh, plugins, aliases, and shell paths
- Ghostty and tmux configuration
- Node.js and global npm packages through mise

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
| `make check` | Run the test suite |
| `make macos-defaults` | Apply Finder, screenshot, Preview, and Library visibility defaults |
| `make macos-hostname` | Set the computer name (not part of the full setup) |
| `make brew` | Install Homebrew, update it, and upgrade packages |
| `make brew-bundle` | Install what is missing from the `Brewfile` |
| `make git-install` | Link Git dotfiles |
| `make code-install` | Link VS Code settings and keybindings |
| `make code-extensions` | Install VS Code extensions |
| `make ghostty-install` | Link Ghostty config |
| `make tmux-install` | Link tmux config and install its plugin manager |
| `make zsh` | Install Oh My Zsh, plugins, and `z.sh` |
| `make node` | Install Node.js and global npm packages with mise |

The full setup does not upgrade packages that are already installed. Run `make brew` for that.

## Terminal Tools

| Tool | Used for |
| --- | --- |
| `ghostty` | Terminal, configured in `ghostty/config` |
| `tmux` | Multiplexer. Press `prefix + I` once to install its plugins |
| `starship` | Prompt. Setup creates the gruvbox-rainbow preset if you have no config |
| `ripgrep`, `fd` | Search. `grep` and `find` are not aliased because their flags differ |
| `git-delta`, `difftastic` | Diffs |
| `mise` | Node.js and global npm packages, from `mise/config.toml`. Also reads `.nvmrc` and `.node-version` |
| `uv` | Python |
| `jenv`, `tfenv`, `tgenv` | Java, Terraform, and Terragrunt versions |

## Layout

```text
.
|-- Brewfile      CLI packages, GUI apps, and fonts
|-- install.sh    One-click installer: fetches the repo, then runs setup.sh
|-- setup.sh      Every setup step, as functions, plus the menu
|-- uninstall.sh  Every removal step
|-- zsh.env       Shared Zsh configuration, sourced by ~/.zshrc
|-- code/         VS Code settings and keybindings
|-- ghostty/      Ghostty config
|-- git/          Git config, ignore rules, attributes, commit template
|-- mise/         Node.js and global npm packages
|-- tmux/         tmux config
`-- tests/        Test suite
```

## Customizing

- **Packages:** edit `Brewfile`.
- **Node.js version, global npm packages:** edit `mise/config.toml`, then run `make node`.
- **VS Code extensions, computer name:** edit the values at the top of `setup.sh`.
- **Shell config for every machine:** edit `zsh.env`.
- **Shell config for one machine:** edit `~/.zshrc`. It is not tracked, and it only needs to keep the line that sources `zsh.env`. Installers that append to it no longer dirty the repo.

Git, VS Code, Ghostty, tmux, and mise files are symlinked, so edits take effect immediately. An existing file is copied to `<file>.backup.<timestamp>` before it is replaced or edited.

## Testing

```sh
make check                 # everything
tests/run-tests.sh static  # script headers, syntax, shellcheck, Brewfile
tests/run-tests.sh flow    # install, re-run, migration, and uninstall flows
```

The flow tests use a throwaway `HOME` with stubs for anything that installs or changes the system, so they are safe to run on a configured machine. They check the scripts' logic, not that Homebrew or the installers really work.

## Uninstall

```sh
make uninstall
```

This removes Homebrew and casks, VS Code user data, Git dotfiles, mise, Ghostty and tmux config, Zsh files, Oh My Zsh, and shell history. Read `uninstall.sh` first: these commands permanently delete files from `$HOME` and application support directories. Use `make brew-uninstall`, `code-uninstall`, `git-uninstall`, `node-uninstall`, `terminal-uninstall`, or `zsh-uninstall` to remove one part.
