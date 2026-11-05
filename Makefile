SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := help

DOTFILES_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
BASH := /bin/bash
SETUP := $(BASH) "$(DOTFILES_DIR)/setup.sh"
UNINSTALL := $(BASH) "$(DOTFILES_DIR)/uninstall.sh"

.PHONY: help install uninstall sync check \
	macos-defaults macos-hostname \
	brew brew-bundle brew-uninstall \
	code-install code-extensions code-uninstall \
	node node-uninstall \
	zsh zsh-uninstall \
	git-install git-uninstall

help:
	@printf '%s\n' \
		'install           Run full dotfiles install' \
		'uninstall         Run full dotfiles uninstall' \
		'sync              Refresh symlinks and ~/.zshrc' \
		'check             Run the test suite' \
		'macos-defaults    Apply macOS defaults' \
		'macos-hostname    Set macOS computer name' \
		'brew              Install Homebrew, update it, and upgrade packages' \
		'brew-bundle       Install what is missing from the Brewfile' \
		'brew-uninstall    Remove Homebrew, casks, and /opt/homebrew' \
		'code-install      Link VS Code settings and keybindings' \
		'code-extensions   Install VS Code extensions' \
		'code-uninstall    Remove VS Code files' \
		'node              Install Volta, Node.js, and global packages' \
		'node-uninstall    Remove Volta files' \
		'zsh               Install Oh My Zsh and plugins' \
		'zsh-uninstall     Remove Zsh and Oh My Zsh files' \
		'git-install       Link Git dotfiles' \
		'git-uninstall     Remove Git dotfiles'

install:
	$(BASH) "$(DOTFILES_DIR)/install.sh"

uninstall:
	$(UNINSTALL)

sync:
	$(SETUP) config

check:
	$(BASH) "$(DOTFILES_DIR)/tests/run-tests.sh"

macos-defaults:
	$(SETUP) macos-defaults

macos-hostname:
	$(SETUP) macos-hostname

brew:
	$(SETUP) brew

brew-bundle:
	$(SETUP) brew-bundle

brew-uninstall:
	$(UNINSTALL) brew

code-install:
	$(SETUP) code

code-extensions:
	$(SETUP) code-extensions

code-uninstall:
	$(UNINSTALL) code

node:
	$(SETUP) node

node-uninstall:
	$(UNINSTALL) node

zsh:
	$(SETUP) zsh

zsh-uninstall:
	$(UNINSTALL) zsh

git-install:
	$(SETUP) git

git-uninstall:
	$(UNINSTALL) git
