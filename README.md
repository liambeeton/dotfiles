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

## Git Configuration

### Git Config SymbolicLink

```
New-Item -Path "C:\Users\Liam\.gitconfig" -ItemType SymbolicLink -Value "C:\Projects\dotfiles\git\.gitconfig" -Force
```

### Git Ignore Global SymbolicLink

```
New-Item -Path "C:\Users\Liam\.gitignore_global" -ItemType SymbolicLink -Value "C:\Projects\dotfiles\git\.gitignore_global" -Force
```

## Slack Configuration

### Custom Scheme

```
#373D48,#303641,#5294E2,#FFFFFF,#4A5664,#FFFFFF,#5294E2,#5294E2
```
