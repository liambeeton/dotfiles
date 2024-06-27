#!/bin/zsh

# Exit on first error
set -e

# Remove files and folders
rm -rf ~/Library/Preferences/com.microsoft.VSCode.helper.plist
rm -rf ~/Library/Preferences/com.microsoft.VSCode.plist
rm -rf ~/Library/Caches/com.microsoft.VSCode
rm -rf ~/Library/Caches/com.microsoft.VSCode.ShipIt/
rm -rf ~/Library/Application\ Support/Code/
rm -rf ~/Library/Saved\ Application\ State/com.microsoft.VSCode.savedState/
rm -rf ~/.vscode/
