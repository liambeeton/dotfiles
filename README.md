# dotfiles

## [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy)

### Install

```
npm install -g diff-so-fancy
```

## [Fira Code](https://github.com/tonsky/FiraCode)

### Install

```
choco install -y firacode-ttf
```

## Git

### Config SymbolicLink

```
New-Item -Path "C:\Users\Liam\.gitconfig" -ItemType SymbolicLink -Value "C:\Projects\dotfiles\git\.gitconfig" -Force
```

### Ignore SymbolicLink

```
New-Item -Path "C:\Users\Liam\.gitignore_global" -ItemType SymbolicLink -Value "C:\Projects\dotfiles\git\.gitignore_global" -Force
```

## Slack

### Custom Scheme

```
#373D48,#303641,#5294E2,#FFFFFF,#4A5664,#FFFFFF,#5294E2,#5294E2
```

## Visual Studio Code

### Settings SymbolicLink

```
New-Item -Path "C:\Users\Liam\AppData\Roaming\Code\User\settings.json" -ItemType SymbolicLink -Value "C:\Projects\dotfiles\vscode\settings.json" -Force
```
