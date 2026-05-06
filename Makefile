SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := help

DOTFILES_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
BASH := /bin/bash

.PHONY: help install uninstall remote-install \
	check \
	macos-defaults macos-hostname \
	brew brew-packages brew-casks brew-uninstall \
	code-install code-extensions code-uninstall \
	node node-uninstall \
	zsh zsh-uninstall \
	git-uninstall

help:
	@printf '%s\n' \
		'install           Run full dotfiles install' \
		'uninstall         Run full dotfiles uninstall' \
		'remote-install    Run remote bootstrap install' \
		'check             Verify shell script headers and syntax' \
		'macos-defaults    Apply macOS defaults' \
		'macos-hostname    Set macOS computer name' \
		'brew              Install Homebrew and update it' \
		'brew-packages     Install Homebrew CLI packages' \
		'brew-casks        Install Homebrew casks' \
		'brew-uninstall    Remove Homebrew, casks, and /opt/homebrew' \
		'code-install      Link VS Code settings and keybindings' \
		'code-extensions   Install VS Code extensions' \
		'code-uninstall    Remove VS Code files' \
		'node              Install Volta, Node.js, and global packages' \
		'node-uninstall    Remove Volta files' \
		'zsh               Install Oh My Zsh and plugins' \
		'zsh-uninstall     Remove Zsh and Oh My Zsh files' \
		'git-uninstall     Remove Git dotfiles'

install:
	$(BASH) "$(DOTFILES_DIR)/install.sh"

uninstall:
	$(BASH) "$(DOTFILES_DIR)/uninstall.sh"

remote-install:
	$(BASH) "$(DOTFILES_DIR)/remote-install.sh"

check:
	@while IFS= read -r script; do \
		[[ "$$(sed -n '1p' "$$script")" == '#!/bin/bash' ]] || { echo "$$script: missing #!/bin/bash"; exit 1; }; \
		[[ -z "$$(sed -n '2p' "$$script")" ]] || { echo "$$script: expected blank line after shebang"; exit 1; }; \
		[[ "$$(sed -n '3p' "$$script")" == 'set -euo pipefail' ]] || { echo "$$script: missing set -euo pipefail"; exit 1; }; \
		bash -n "$$script"; \
	done < <(find "$(DOTFILES_DIR)" -type f -name '*.sh' -not -path '*/.git/*' | sort)

macos-defaults:
	$(BASH) "$(DOTFILES_DIR)/macos/defaults.sh"

macos-hostname:
	$(BASH) "$(DOTFILES_DIR)/macos/hostname.sh"

brew:
	$(BASH) "$(DOTFILES_DIR)/brew/brew.sh"

brew-packages:
	$(BASH) "$(DOTFILES_DIR)/brew/brew-package.sh"

brew-casks:
	$(BASH) "$(DOTFILES_DIR)/brew/brew-cask.sh"

brew-uninstall:
	$(BASH) "$(DOTFILES_DIR)/brew/uninstall.sh"

code-install:
	$(BASH) "$(DOTFILES_DIR)/code/install.sh"

code-extensions:
	$(BASH) "$(DOTFILES_DIR)/code/extensions.sh"

code-uninstall:
	$(BASH) "$(DOTFILES_DIR)/code/uninstall.sh"

node:
	$(BASH) "$(DOTFILES_DIR)/node/npm.sh"

node-uninstall:
	$(BASH) "$(DOTFILES_DIR)/node/uninstall.sh"

zsh:
	$(BASH) "$(DOTFILES_DIR)/zsh/zsh.sh"

zsh-uninstall:
	$(BASH) "$(DOTFILES_DIR)/zsh/uninstall.sh"

git-uninstall:
	$(BASH) "$(DOTFILES_DIR)/git/uninstall.sh"
