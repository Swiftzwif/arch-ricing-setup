# Zsh Configuration File
# Ultimate Ricing Setup for Arch Linux
# Enhanced with Oh My Zsh and Starship prompt

# =================================
# ZSH CONFIGURATION
# =================================

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme selection (using starship instead)
ZSH_THEME=""

# Case-sensitive completion
CASE_SENSITIVE="false"

# Hyphen-insensitive completion
HYPHEN_INSENSITIVE="true"

# Auto-update behavior
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 13

# Disable marking untracked files under VCS as dirty
DISABLE_UNTRACKED_FILES_DIRTY="true"

# History timestamp format
HIST_STAMPS="yyyy-mm-dd"

# Custom folder
ZSH_CUSTOM="$ZSH/custom"

# =================================
# PLUGINS
# =================================

plugins=(
    git
    sudo
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    command-not-found
    colored-man-pages
    copyfile
    copydir
    copybuffer
    dirhistory
    history
    jsontools
    web-search
    extract
    z
    docker
    docker-compose
    npm
    node
    python
    pip
    golang
    rust
    archlinux
    systemd
    ssh-agent
    gpg-agent
    thefuck
    fzf
    fd
    ripgrep
    bat
    exa
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# =================================
# USER CONFIGURATION
# =================================

# Export language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# =================================
# PATH CONFIGURATION
# =================================

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Add cargo bin to PATH (Rust)
export PATH="$HOME/.cargo/bin:$PATH"

# Add Go bin to PATH
export PATH="$HOME/go/bin:$PATH"
export PATH="/usr/local/go/bin:$PATH"

# Add npm global bin to PATH
export PATH="$HOME/.npm-global/bin:$PATH"

# Add Python user bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Add custom scripts to PATH
export PATH="$HOME/.config/scripts:$PATH"

# =================================
# ENVIRONMENT VARIABLES
# =================================

# Default browser
export BROWSER="firefox"

# Default terminal
export TERMINAL="kitty"

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Development environment
export GOPATH="$HOME/go"
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"
export NPM_CONFIG_PREFIX="$HOME/.npm-global"

# Wayland environment
export QT_QPA_PLATFORM="wayland;xcb"
export GDK_BACKEND="wayland,x11"
export MOZ_ENABLE_WAYLAND=1
export XDG_CURRENT_DESKTOP="Hyprland"
export XDG_SESSION_DESKTOP="Hyprland"
export XDG_SESSION_TYPE="wayland"

# =================================
# HISTORY CONFIGURATION
# =================================

# History file
HISTFILE="$HOME/.zsh_history"

# History size
HISTSIZE=50000
SAVEHIST=50000

# History options
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits
setopt SHARE_HISTORY             # Share history between all sessions
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file
setopt HIST_VERIFY               # Do not execute immediately upon history expansion
setopt APPEND_HISTORY            # Append to history file
setopt HIST_NO_STORE             # Don't store history commands

# =================================
# ZSH OPTIONS
# =================================

# Directory options
setopt AUTO_CD                   # Change to a directory just by typing its name
setopt AUTO_PUSHD                # Make cd push the old directory onto the directory stack
setopt PUSHD_IGNORE_DUPS         # Don't push the same directory onto the stack twice
setopt PUSHD_MINUS               # Exchanges + and - for pushd

# Completion options
setopt COMPLETE_ALIASES          # Complete aliases
setopt COMPLETE_IN_WORD          # Complete from both ends of a word
setopt ALWAYS_TO_END             # Move cursor to the end of a completed word
setopt AUTO_MENU                 # Show completion menu on a successive tab press
setopt AUTO_LIST                 # Automatically list choices on ambiguous completion
setopt AUTO_PARAM_SLASH          # If completed parameter is a directory, add a trailing slash
setopt FLOW_CONTROL              # Enable flow control

# Correction options
setopt CORRECT                   # Enable command correction
setopt CORRECT_ALL               # Enable argument correction

# Prompt options
setopt PROMPT_SUBST              # Enable parameter expansion, command substitution, and arithmetic expansion in prompts

# Globbing options
setopt EXTENDED_GLOB             # Use extended globbing syntax
setopt GLOB_DOTS                 # Include dotfiles in globbing

# Job control options
setopt AUTO_RESUME               # Resume jobs automatically
setopt LONG_LIST_JOBS            # List jobs in the long format by default
setopt NOTIFY                    # Report the status of background jobs immediately

# =================================
# ALIASES
# =================================

# System commands
alias l='exa -la --icons --group-directories-first'
alias ll='exa -l --icons --group-directories-first'
alias la='exa -la --icons --group-directories-first'
alias lt='exa -aT --icons --group-directories-first'
alias ls='exa --icons --group-directories-first'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# File operations
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'

# Editor aliases
alias vim='nvim'
alias vi='nvim'
alias nano='nvim'

# Git aliases
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gapa='git add --patch'
alias gau='git add --update'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbda='git branch --no-color --merged | command grep -vE "^(\*|\s*(master|develop|dev)\s*$)" | command xargs -n 1 git branch -d'
alias gbl='git blame -b -w'
alias gbnm='git branch --no-merged'
alias gbr='git branch --remote'
alias gbs='git bisect'
alias gbsb='git bisect bad'
alias gbsg='git bisect good'
alias gbsr='git bisect reset'
alias gbss='git bisect start'
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gca='git commit -v -a'
alias gca!='git commit -v -a --amend'
alias gcam='git commit -a -m'
alias gcan!='git commit -v -a --no-edit --amend'
alias gcans!='git commit -v -a -s --no-edit --amend'
alias gcb='git checkout -b'
alias gcd='git checkout develop'
alias gcf='git config --list'
alias gch='git checkout'
alias gchm='git checkout master'
alias gcl='git clone --recurse-submodules'
alias gclean='git clean -fd'
alias gcm='git checkout master'
alias gcmsg='git commit -m'
alias gco='git checkout'
alias gcount='git shortlog -sn'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gcs='git commit -S'
alias gd='git diff'
alias gdca='git diff --cached'
alias gdct='git describe --tags `git rev-list --tags --max-count=1`'
alias gdt='git diff-tree --no-commit-id --name-only -r'
alias gdw='git diff --word-diff'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfo='git fetch origin'
alias gg='git gui citool'
alias gga='git gui citool --amend'
alias ggpull='git pull origin $(git_current_branch)'
alias ggpush='git push origin $(git_current_branch)'
alias ggsup='git branch --set-upstream-to=origin/$(git_current_branch)'
alias ghh='git help'
alias gignore='git update-index --assume-unchanged'
alias gignored='git ls-files -v | grep "^[[:lower:]]"'
alias git-svn-dcommit-push='git svn dcommit && git push github master:svntrunk'
alias gk='\gitk --all --branches'
alias gke='\gitk --all $(git log -g --pretty=%h)'
alias gl='git pull'
alias glg='git log --stat'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glgm='git log --graph --max-count=10'
alias glgp='git log --stat -p'
alias glo='git log --oneline --decorate'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias glol='git log --graph --pretty='\''%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'\'' --abbrev-commit'
alias glola='git log --graph --pretty='\''%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'\'' --abbrev-commit --all'
alias glp='_git_log_prettily'
alias gm='git merge'
alias gmom='git merge origin/master'
alias gmt='git mergetool --no-prompt'
alias gmtvim='git mergetool --no-prompt --tool=vimdiff'
alias gmum='git merge upstream/master'
alias gp='git push'
alias gpd='git push --dry-run'
alias gpoat='git push origin --all && git push origin --tags'
alias gpristine='git reset --hard && git clean -dfx'
alias gpsup='git push --set-upstream origin $(git_current_branch)'
alias gpu='git push upstream'
alias gpv='git push -v'
alias gr='git remote'
alias gra='git remote add'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'
alias grbm='git rebase master'
alias grbs='git rebase --skip'
alias grep='grep --color'
alias grh='git reset HEAD'
alias grhh='git reset HEAD --hard'
alias grmv='git remote rename'
alias grrm='git remote remove'
alias grset='git remote set-url'
alias grt='cd $(git rev-parse --show-toplevel || echo ".")'
alias gru='git reset --'
alias grup='git remote update'
alias grv='git remote -v'
alias gsb='git status -sb'
alias gsd='git svn dcommit'
alias gsi='git submodule init'
alias gsps='git show --pretty=short --show-signature'
alias gsr='git svn rebase'
alias gss='git status -s'
alias gst='git status'
alias gsta='git stash save'
alias gstaa='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --text'
alias gsu='git submodule update'
alias gts='git tag -s'
alias gtv='git tag | sort -V'
alias gunignore='git update-index --no-assume-unchanged'
alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'
alias gup='git pull --rebase'
alias gupv='git pull --rebase -v'
alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify -m "--wip-- [skip ci]"'

# Package management (Arch Linux)
alias pac='sudo pacman -S'
alias pacs='pacman -Ss'
alias pacu='sudo pacman -Syu'
alias pacr='sudo pacman -R'
alias pacrs='sudo pacman -Rs'
alias pacrc='sudo pacman -Sc'
alias pacrcc='sudo pacman -Scc'
alias pacq='pacman -Q'
alias pacqs='pacman -Qs'
alias pacql='pacman -Ql'
alias pacqi='pacman -Qi'
alias yay='yay --color=auto'
alias yayu='yay -Syu'
alias yays='yay -Ss'

# System monitoring
alias htop='htop -C'
alias ps='ps auxf'
alias psgrep='ps aux | grep -v grep | grep -i -e VSZ -e'
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'
alias df='df -H'
alias du='du -ch'
alias free='free -mt'

# Network
alias ping='ping -c 5'
alias wget='wget -c'
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -'

# Docker
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs'
alias dlogf='docker logs -f'
alias dstop='docker stop'
alias dstart='docker start'
alias drm='docker rm'
alias drmi='docker rmi'
alias dcp='docker-compose'
alias dcpup='docker-compose up -d'
alias dcpdown='docker-compose down'
alias dcplogs='docker-compose logs -f'

# Development
alias py='python'
alias py3='python3'
alias ipy='ipython'
alias pip3install='pip3 install --user'
alias serve='python -m http.server'
alias js='node'
alias nrd='npm run dev'
alias nrs='npm run start'
alias nrb='npm run build'
alias nrt='npm run test'
alias yr='yarn'
alias yrd='yarn dev'
alias yrs='yarn start'
alias yrb='yarn build'
alias yrt='yarn test'

# Text processing
alias cat='bat'
alias less='bat'
alias grep='rg'
alias find='fd'

# System
alias myip='curl http://ipecho.net/plain; echo'
alias ports='netstat -tulanp'
alias meminfo='free -m -l -t'
alias cpuinfo='lscpu'
alias diskinfo='df -h'
alias systeminfo='inxi -Fxz'
alias weather='curl wttr.in'
alias clock='tty-clock -c -C 4 -r -s'

# Quick config edits
alias zshconfig='nvim ~/.zshrc'
alias hyprconfig='nvim ~/.config/hypr/hyprland.conf'
alias waybarconfig='nvim ~/.config/waybar/config'
alias kittyconfig='nvim ~/.config/kitty/kitty.conf'
alias nvimconfig='nvim ~/.config/nvim/init.lua'

# Shortcuts
alias h='history'
alias j='jobs -l'
alias which='type -a'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'

# =================================
# FUNCTIONS
# =================================

# Extract function
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Make directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find file by name
ff() {
    find . -name "*$1*"
}

# Find process by name
fps() {
    ps aux | grep -i "$1" | grep -v grep
}

# Git clone and cd
gclone() {
    git clone "$1" && cd "$(basename "$1" .git)"
}

# Quick backup
backup() {
    cp "$1"{,.bak}
}

# Show colors
colors() {
    for i in {0..255}; do
        printf "\x1b[48;5;%sm%3d\e[0m " "$i" "$i"
        if (( i == 15 )) || (( i > 15 )) && (( (i-15) % 6 == 0 )); then
            printf "\n";
        fi
    done
}

# =================================
# FZF CONFIGURATION
# =================================

# FZF options
export FZF_DEFAULT_OPTS="
--height 40%
--layout=reverse
--border
--preview 'bat --style=numbers --color=always --line-range :500 {}'
--color=fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7
--color=fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff
--color=info:#7dcfff,prompt:#7dcfff,pointer:#7dcfff
--color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
"

# Use fd for FZF
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# =================================
# COMPLETION CONFIGURATION
# =================================

# Initialize completion system
autoload -Uz compinit
compinit

# Completion options
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

# =================================
# STARSHIP PROMPT
# =================================

# Initialize Starship prompt
eval "$(starship init zsh)"

# =================================
# ADDITIONAL TOOLS
# =================================

# Load thefuck if available
if command -v thefuck &> /dev/null; then
    eval $(thefuck --alias)
fi

# Load zoxide if available
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# Load direnv if available
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi

# Load nvm if available
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# =================================
# WELCOME MESSAGE
# =================================

# Display system information on new shell
if [[ -o interactive ]] && command -v neofetch &> /dev/null; then
    neofetch
fi

# Display fortune if available
if command -v fortune &> /dev/null; then
    echo
    fortune
    echo
fi