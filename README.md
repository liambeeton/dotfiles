# 🏠 Dotfiles

This repository contains my personal dotfiles and development environment setup for macOS. It automates the configuration of essential development tools including Git, Node.js, Homebrew, Zsh, and VS Code.

## ✨ Features

- **🔧 Automated Setup**: One-command installation and configuration
- **🍺 Homebrew Integration**: Automated package and application installation
- **⚡ Zsh Configuration**: Enhanced shell experience with Oh My Zsh
- **🔗 Git Configuration**: Global Git settings and aliases
- **📦 Node.js Environment**: Node version management and global packages
- **💻 VS Code Setup**: Extensions, settings, and keybindings sync
- **🔄 Easy Updates**: Simple commands to keep everything in sync

## 🖥️ System Requirements

- **OS**: macOS 10.15+ (Catalina or later)
- **Shell**: Zsh (default on macOS Catalina+)
- **Xcode Command Line Tools**: Automatically installed if missing

## 🚀 Quick Start

### Fresh Installation

```bash
# Software update
sudo softwareupdate -i -a

# Install git
xcode-select --install

# Install rosetta
softwareupdate --install-rosetta --agree-to-license

# Clone the repository
git clone https://github.com/liambeeton/dotfiles.git ~/.dotfiles

# Navigate to the directory
cd ~/.dotfiles

# Run the installation script
./install.sh
```

### Existing Setup Update

```bash
# Navigate to dotfiles directory
cd ~/.dotfiles

# Pull latest changes and update
git pull && ./update.sh
```

## 📁 Repository Structure

```
~/.dotfiles/
├── install.sh              # Main installation script
├── update.sh               # Update existing installation
├── Brewfile                # Homebrew packages and applications
├── git/                    # Git configuration
│   ├── .gitconfig
│   └── .gitignore_global
├── zsh/                    # Zsh configuration
│   ├── .zshrc
│   ├── .zshenv
│   └── aliases.zsh
├── node/                   # Node.js configuration
│   ├── .nvmrc
│   └── global-packages.txt
├── vscode/                 # VS Code configuration
│   ├── settings.json
│   ├── keybindings.json
│   └── extensions.txt
├── macos/                  # macOS system preferences
│   └── defaults.sh
└── scripts/                # Utility scripts
    ├── backup.sh
    └── restore.sh
```

## 🔧 What Gets Configured

### 🍺 Homebrew Packages

The `Brewfile` includes essential development tools:

**CLI Tools:**

- git, node, python3, ruby
- wget, curl, jq, tree
- bat, exa, ripgrep, fzf
- docker, kubectl, terraform

**Applications:**

- Visual Studio Code
- Google Chrome
- Docker Desktop
- Postman
- Rectangle (window management)

### ⚡ Zsh Configuration

- **Oh My Zsh** with curated plugins
- **Custom aliases** for common commands
- **Enhanced prompt** with git status
- **Auto-completion** improvements
- **History optimization**

Key aliases included:

```bash
alias ll='exa -la'
alias g='git'
alias gst='git status'
alias code='code-insiders'
alias brewup='brew update && brew upgrade'
```

### 🔗 Git Configuration

- Global user configuration
- Useful aliases for common workflows
- Enhanced diff and merge tools
- Global gitignore for common files

### 📦 Node.js Setup

- **NVM** (Node Version Manager) installation
- Latest LTS Node.js version
- Essential global packages:
  - npm, yarn, pnpm
  - eslint, prettier
  - typescript, ts-node
  - nodemon, pm2

### 💻 VS Code Configuration

**Essential Extensions:**

- GitLens
- Prettier
- ESLint
- Auto Rename Tag
- Bracket Pair Colorizer
- Material Icon Theme

**Settings:**

- Consistent formatting rules
- Custom keybindings
- Theme and font preferences
- Integrated terminal configuration

### 🖥️ macOS Defaults

- Dock preferences
- Finder enhancements
- Trackpad and mouse settings
- Security and privacy defaults

## 🔒 Backup & Safety

Before running the installation, the script automatically:

- **Creates backups** of existing dotfiles in `~/.dotfiles-backup/`
- **Checks for conflicts** and prompts for confirmation
- **Provides rollback options** via `scripts/restore.sh`

To manually backup your current configuration:

```bash
./scripts/backup.sh
```

To restore from backup:

```bash
./scripts/restore.sh
```

## 🎨 Customization

### Personal Information

Edit `git/.gitconfig` to update:

```ini
[user]
    name = Your Name
    email = your.email@example.com
```

### Additional Packages

Add packages to `Brewfile`:

```ruby
# CLI tools
brew "your-package"

# Applications
cask "your-application"
```

### Zsh Customization

Edit `zsh/.zshrc` to modify:

- Plugins: `plugins=(git node npm docker)`
- Theme: `ZSH_THEME="robbyrussell"`
- Custom aliases in `zsh/aliases.zsh`

### VS Code Extensions

Add extensions to `vscode/extensions.txt`:

```
ms-vscode.extension-name
```

## 🔄 Keeping Updated

### Update Dotfiles

```bash
cd ~/.dotfiles && git pull
./update.sh
```

### Update Homebrew Packages

```bash
brew update && brew upgrade
```

### Update Node.js

```bash
nvm install node --reinstall-packages-from=node
```

### Sync VS Code Extensions

```bash
./scripts/sync-vscode.sh
```

## 🐛 Troubleshooting

### Common Issues

**Installation fails with permission errors:**

```bash
sudo xcode-select --install
sudo chown -R $(whoami) /usr/local/share/zsh
```

**Homebrew command not found:**

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

**NVM command not found:**

```bash
source ~/.zshrc
# or
nvm --version
```

**VS Code settings not syncing:**

- Enable Settings Sync in VS Code
- Check `vscode/settings.json` permissions

### Reset Everything

To completely reset and reinstall:

```bash
./scripts/reset.sh  # Removes all configurations
./install.sh       # Fresh installation
```

## 🤝 Contributing

- Fork the repository
- Create a feature branch (`git checkout -b feature/amazing-feature`)
- Commit your changes (`git commit -m 'Add some amazing feature'`)
- Push to the branch (`git push origin feature/amazing-feature`)
- Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles) for macOS defaults inspiration
- [Oh My Zsh](https://ohmyz.sh/) for the amazing Zsh framework
- [Homebrew](https://brew.sh/) for package management
- The dotfiles community for sharing configurations and best practices

---

**💡 Pro Tip**: Star this repository to keep track of updates and improvements!

For questions or issues, please [open an issue](https://github.com/liambeeton/dotfiles/issues) or reach out on [Twitter](https://twitter.com/liambeeton).
