# dotfiles

My Windows 10 environment and some settings that I use.

## [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy)

### Install

```sh
npm install -g diff-so-fancy
```

## [Fira Code](https://github.com/tonsky/FiraCode)

### Install

```sh
choco install firacode -y
```

## Git

### Config SymbolicLink

```powershell
New-Item -Path "C:\Users\Liam\.gitconfig" -ItemType SymbolicLink -Value "C:\Projects\dotfiles\git\.gitconfig" -Force
```

### Ignore SymbolicLink

```powershell
New-Item -Path "C:\Users\Liam\.gitignore_global" -ItemType SymbolicLink -Value "C:\Projects\dotfiles\git\.gitignore_global" -Force
```

## Slack

### Custom Scheme

```sh
#373D48,#303641,#5294E2,#FFFFFF,#4A5664,#FFFFFF,#5294E2,#5294E2
```

```sh
#282A36,#44475A,#44475A,#50FA7B,#6272A4,#FFFFFF,#50FA7B,#FF5555
```

## Visual Studio Code

### Settings SymbolicLink

```powershell
New-Item -Path "C:\Users\Liam\AppData\Roaming\Code\User\settings.json" -ItemType SymbolicLink -Value "C:\Projects\dotfiles\vscode\settings.json" -Force
```

## SSH Key

### Generate Key

```sh
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

### Config SymbolicLink

```powershell
New-Item -Path "C:\Users\Liam\.ssh\config" -ItemType SymbolicLink -Value "C:\Projects\dotfiles\ssh\config" -Force
```

## Windows Terminal

### Posh Git

```sh
Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser
```

NB: code $PROFILE

### Settings

```sh
"colorScheme": "Monokai Night",
"fontFace": "CaskaydiaCove NF",
"fontSize": 12,
"startingDirectory": "C:\\Projects"
```

Reference: https://www.hanselman.com/blog/taking-your-powershell-prompt-to-the-next-level-with-windows-terminal-and-oh-my-posh-3