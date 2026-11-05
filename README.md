# dotfiles

Personal macOS dotfiles and bootstrap scripts. One command sets up a development workstation, and re-running it only does what is missing.

- macOS Finder, Dock, keyboard, text input, screenshot, and Preview defaults
- Touch ID for `sudo`, the firewall, and a FileVault check
- Homebrew, CLI packages, and GUI casks from a `Brewfile`
- Git configuration, global ignore rules, attributes, and commit template
- VS Code settings, keybindings, and extensions
- Zsh, Oh My Zsh, plugins, aliases, and shell paths
- Ghostty and tmux configuration
- Java, Node.js, Terraform, Terragrunt, and global npm packages through mise

These scripts are personal and intentionally opinionated. Review them before running on a machine you do not want fully reconfigured.

Requires macOS on Apple Silicon (Homebrew paths assume `/opt/homebrew`) and admin access.

## Prerequisites

**Run these before installing, in this order.** The scripts do not run them for you.

```sh
softwareupdate --install --all
xcode-select --install
```

1. Install all macOS updates. Restart if any of them ask you to.
2. Install the Xcode Command Line Tools. This opens a dialog, so wait for it to finish before moving on.

### Optional: Rosetta

Nothing in this setup is known to need Rosetta, and you can install it at any time. Install it if you run `linux/amd64` Docker images regularly, or use an Intel-only tool that fails with `Bad CPU type in executable`. macOS normally offers to install it the first time you open an Intel-only app.

```sh
softwareupdate --install-rosetta --agree-to-license
```

Using this command accepts Apple's license agreement for Rosetta.

## Install

The setup only checks FileVault and warns if it is off, because enabling it prints a recovery key you must save. To enable it, run `sudo fdesetup enable`.

If a step fails, the others still run. A summary at the end lists what failed and anything left for you to do, such as logging out, and the run exits with an error. Fix the cause and run it again.

If a cask fails because you already installed that app by hand, either delete the app or run `brew install --cask --adopt <cask>` if it is the same version, and then run the setup again.

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
| `make doctor` | Report what has drifted from this repo, changing nothing |
| `make check` | Run the test suite |
| `make macos-defaults` | Apply macOS defaults and restart Finder and the Dock. Log out and back in for the keyboard settings |
| `make macos-security` | Enable Touch ID for `sudo` and the firewall, and check FileVault |
| `make macos-hostname` | Set the computer name (not part of the full setup) |
| `make brew` | Install Homebrew, update it, and upgrade packages |
| `make brew-bundle` | Install what is missing from the `Brewfile` |
| `make git-install` | Link Git dotfiles |
| `make code-install` | Link VS Code settings and keybindings |
| `make code-extensions` | Install VS Code extensions |
| `make ghostty-install` | Link Ghostty config |
| `make tmux-install` | Link tmux config and install its plugin manager |
| `make zsh` | Install Oh My Zsh and plugins |
| `make mise` | Install Java, Node.js, Terraform, Terragrunt, and global npm packages |

The full setup does not upgrade packages that are already installed. Run `make brew` for that.

## Checking a Machine

`make doctor` checks that everything in the `Brewfile` is installed, that `mise doctor` reports no problems, and that every config file is still linked to this repo. It only reads, lists each problem with the command that fixes it, and exits with an error if it finds any. Run it from a terminal opened after setup, because `mise doctor` also reports when mise is not activated in the current shell.

## Terminal Tools

| Tool | Used for |
| --- | --- |
| `ghostty` | Terminal, configured in `ghostty/config` |
| `tmux` | Multiplexer. Press `prefix + I` once to install its plugins |
| `starship` | Prompt. Setup creates the gruvbox-rainbow preset if you have no config |
| `eza`, `bat` | `ls` and `cat`, through aliases |
| `ripgrep`, `fd` | Search. `grep` and `find` are not aliased because their flags differ |
| `fzf` | Fuzzy finder: `ctrl-t` for files, `alt-c` for directories |
| `atuin` | Searchable history on `ctrl-r`. The up arrow is unchanged |
| `zoxide` | Directory jumping with `z` and `zi` |
| `yazi` | File manager |
| `lazygit` | Git TUI |
| `git-delta`, `difftastic` | Diffs |
| `bottom` (`btm`), `procs` | System monitor and `ps` replacement |
| `tealdeer` (`tldr`), `tokei` (`loc`), `ouch` | Command examples, code statistics, compression |
| `mise` | Java (Corretto), Node.js, Terraform, Terragrunt, and global npm packages, from `mise/config.toml`. Also reads each tool's version file in a project, such as `.java-version` or `.terraform-version` |
| `uv` | Python |

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
|-- mise/         Language runtimes, infrastructure tools, global npm packages
|-- tmux/         tmux config
`-- tests/        Test suite
```

## Customizing

- **Packages:** edit `Brewfile`.
- **Java, Node.js, Terraform, Terragrunt, global npm packages:** edit `mise/config.toml`, then run `make mise`.
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

This removes Homebrew and casks, VS Code user data, Git dotfiles, mise, Ghostty and tmux config, Zsh files, Oh My Zsh, and shell history, including Atuin's. Read `uninstall.sh` first: these commands permanently delete files from `$HOME` and application support directories. Use `make brew-uninstall`, `code-uninstall`, `git-uninstall`, `mise-uninstall`, `terminal-uninstall`, or `zsh-uninstall` to remove one part.
