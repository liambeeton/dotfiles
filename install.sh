#!/usr/bin/env bash

# One-click installer: clones the repo if needed, then runs the full setup.
# Usage: curl -fsSL https://raw.githubusercontent.com/liambeeton/dotfiles/main/install.sh | bash
#    or: ./install.sh

set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/liambeeton/dotfiles.git}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.dotfiles}"

# Does not clear the screen, so earlier output stays in the scrollback.
print_banner() {
  local cyan='' bold='' reset=''
  if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    cyan='\033[0;36m'
    bold='\033[1m'
    reset='\033[0m'
  fi

  printf '%b\n' "${cyan}╭──────────────────────────────────────╮${reset}"
  printf '%b\n' "${cyan}│${reset}  ${bold}dotfiles${reset}                            ${cyan}│${reset}"
  printf '%b\n' "${cyan}│${reset}  macOS development workstation setup ${cyan}│${reset}"
  printf '%b\n' "${cyan}╰──────────────────────────────────────╯${reset}"
}

# Installing Homebrew also installs the Xcode Command Line Tools, which provide
# git, so this has to happen before the repo is cloned.
ensure_homebrew() {
  if ! command -v brew >/dev/null 2>&1 && [[ ! -x /opt/homebrew/bin/brew ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

# Uses the checkout this script is in. When piped into bash there is no script
# file, so falls back to INSTALL_DIR.
resolve_repo() {
  local self="${BASH_SOURCE[0]:-}"

  if [[ -f "$self" && -f "$(dirname -- "$self")/setup.sh" ]]; then
    repo_dir=$(cd -- "$(dirname -- "$self")" && pwd)
  else
    repo_dir="$INSTALL_DIR"
  fi

  if [[ ! -f "$repo_dir/setup.sh" ]]; then
    git clone "$REPO_URL" "$repo_dir"
  elif [[ -d "$repo_dir/.git" ]]; then
    git -C "$repo_dir" pull --ff-only || echo "Could not update $repo_dir, continuing with the current version." >&2
  fi
}

main() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "This script is designed for macOS only." >&2
    exit 1
  fi

  print_banner
  ensure_homebrew

  local repo_dir
  resolve_repo

  # shellcheck source-path=SCRIPTDIR source=setup.sh
  source "$repo_dir/setup.sh"
  setup_all
}

# When piped into bash, stdin is the script rather than the terminal, and the
# Homebrew installer refuses to prompt for a password without a TTY on stdin.
if [[ ! -t 0 ]] && { : </dev/tty; } 2>/dev/null; then
  main "$@" </dev/tty
else
  main "$@"
fi
