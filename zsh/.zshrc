# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  direnv
  git
  kubectl
  pyenv
  z
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# load zsh completions plugin
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

source $ZSH/oh-my-zsh.sh

# get machine's ip address
alias ip="ipconfig getifaddr en0"

# edit global zsh configuration
alias zshconfig="code ~/.zshrc"
# reload zsh configuration
alias zshsource="source ~/.zshrc"
# reload zsh configuration
alias ohmyzsh="cd ~/.oh-my-zsh"

# navigate to global ssh directory
alias sshhome="cd ~/.ssh"
# edit global ssh configuration
alias sshconfig="code ~/.ssh/config"

# edit global git configuration
alias gitconfig="code ~/.gitconfig"

# custom aliases
alias dev="cd ~/Developer"

# git aliases
alias gits="git status"
alias gitd="git diff"
alias gitl="git lg"
alias gita="git add ."
alias gitc="cz commit"
alias gitf='git commit --fixup $(git log -1 --format=%H)'
alias gitm='git branch --merged | egrep -v "(^\\*|main|master|develop)" | xargs -n 1 git branch -d'

# docker aliases
alias docu="docker-compose up"
alias docb="docker-compose build"
alias docd="docker-compose down -v"
alias docs='docker stop $(docker ps -a -q)'
alias docr='docker rm $(docker ps -a -q)'

# hosts config
alias hostsconfig="sudo code /etc/hosts"

# count lines of code
alias loc="npx sloc --format cli-table --format-option head --exclude 'build|\.svg$\.xml' ./"

# use z command
source ~/z.sh

# use android
export ANDROID_HOME="~/Library/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export PATH="$ANDROID_HOME/tools:$PATH"
export PATH="$ANDROID_HOME/tools/bin:$PATH"

# use dotnet
export PATH="$PATH:/usr/local/share/dotnet"

# use golang
export GOPATH="$HOME/go"
export GOROOT="$(brew --prefix golang)/libexec"
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:$GOROOT/bin"

# use jenv
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# use pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
eval "$(pyenv virtualenv-init -)"

# use rust
export PATH="$HOME/.cargo/env:$PATH"

# use volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# use direnv
eval "$(direnv hook zsh)"

# use starship theme (needs to be at the end)
eval "$(starship init zsh)"
