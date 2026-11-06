SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := help

DOTFILES_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
BASH := /bin/bash
SETUP := $(BASH) "$(DOTFILES_DIR)/setup.sh"
UNINSTALL := $(BASH) "$(DOTFILES_DIR)/uninstall.sh"

.PHONY: help install uninstall sync doctor check \
	macos-defaults macos-security macos-hostname macos-remove-apps \
	brew brew-bundle brew-uninstall \
	code-install code-extensions code-uninstall \
	ghostty-install tmux-install terminal-uninstall \
	mise mise-uninstall \
	zsh zsh-uninstall \
	git-install git-uninstall \
	ssh

help:
	@printf '%s\n' \
		'install           Run full dotfiles install' \
		'uninstall         Run full dotfiles uninstall' \
		'sync              Refresh symlinks and ~/.zshrc' \
		'doctor            Report what has drifted from this repo, changing nothing' \
		'check             Run the test suite' \
		'macos-defaults    Apply macOS defaults' \
		'macos-security    Enable Touch ID for sudo and the firewall, check FileVault' \
		'macos-hostname    Set macOS computer name' \
		'macos-remove-apps  Delete GarageBand, its sound library, and iMovie' \
		'brew              Install Homebrew, update it, and upgrade packages' \
		'brew-bundle       Install what is missing from the Brewfile' \
		'brew-uninstall    Remove Homebrew, casks, and /opt/homebrew' \
		'code-install      Link VS Code settings and keybindings' \
		'code-extensions   Install VS Code extensions' \
		'code-uninstall    Remove VS Code files' \
		'ghostty-install   Link Ghostty config' \
		'tmux-install      Link tmux config and install its plugin manager' \
		'terminal-uninstall  Remove Ghostty and tmux config' \
		'mise              Install Java, Node.js, Terraform, Terragrunt, and npm packages' \
		'mise-uninstall    Remove mise files and older version manager files' \
		'zsh               Install Oh My Zsh and plugins' \
		'zsh-uninstall     Remove Zsh and Oh My Zsh files' \
		'git-install       Link Git dotfiles' \
		'git-uninstall     Remove Git dotfiles' \
		'ssh               Create an SSH key for GitHub and add it to the Keychain'

install:
	$(BASH) "$(DOTFILES_DIR)/install.sh"

uninstall:
	$(UNINSTALL)

sync:
	$(SETUP) config

doctor:
	$(SETUP) doctor

check:
	$(BASH) "$(DOTFILES_DIR)/tests/run-tests.sh"

macos-defaults:
	$(SETUP) macos-defaults

macos-security:
	$(SETUP) macos-security

macos-hostname:
	$(SETUP) macos-hostname

macos-remove-apps:
	$(SETUP) macos-remove-apps

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

ghostty-install:
	$(SETUP) ghostty

tmux-install:
	$(SETUP) tmux

terminal-uninstall:
	$(UNINSTALL) terminal

mise:
	$(SETUP) mise

mise-uninstall:
	$(UNINSTALL) mise

zsh:
	$(SETUP) zsh

zsh-uninstall:
	$(UNINSTALL) zsh

git-install:
	$(SETUP) git

git-uninstall:
	$(UNINSTALL) git

ssh:
	$(SETUP) ssh
