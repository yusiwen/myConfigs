#!/usr/bin/env fish

# Make some possibly destructive commands more interactive.
alias rm='rm -iv'
alias mv='mv -iv'
alias cp='cp -iv'

alias less='less -R'

# Add some easy shortcuts for formatted directory listings and add a touch of color.
if ! check_command eza
  if test "$OS" = 'Darwin' 
    alias l='ls -GF'
    alias la='ls -G -aF'
    alias ll='ls -G -alF'
    alias dir='ls -G'
  else
    alias l='vdir -h --format=across --color'
    if check_command ls++
      alias la='ls++ -aF'
      alias ls='ls++ -F'
    else
      alias la='ls -a --color=auto'
      alias ls='ls --color=auto'
      alias ll='ls -la --color=auto'
    end
    alias dir='dir -l --color'
  end
else
  if test "$OS" = 'Darwin'
    alias l='eza --oneline'
    alias la='eza --oneline --all'
    alias ll='eza --long --group'
    alias lla='eza --long --all --group'
    alias dir='ls -G'
  else
    alias l='vdir -h --format=across --color'
    if check_command ls++
      alias la='ls++ -aF'
      alias ls='ls++ -F'
    else
      if eza --version | grep -q '\-git'
        alias la='eza --all --color=always'
        alias ls='eza --color=always'
        alias ll='eza --long --color=always --group'
        alias lla='eza --long --all --color=always --group'
        alias tree='eza --tree --all --color=always'
      else
        alias la='eza --all --git --color=always'
        alias ls='eza --git --color=always'
        alias ll='eza --long --git --color=always --group'
        alias lla='eza --long --all --git --color=always --group'
        alias tree='eza --tree --all --git --color=always'
      end
    end 
    alias dir='dir -l --color'
  end 
end

# On Mac, to enable italic fonts in iTerm2, TERM must be set to 'xterm-256color-italic'.
# If ssh to a remote server, the environment may be passed on the remote and it will probable don't know this custom terminal.
# A possible solution on the local host is to alias ssh
# See 'https://gist.github.com/sos4nt/3187620' for detail
if test "$OS" = 'Darwin'
  alias ssh='TERM=xterm-256color ssh'
end

# Make grep more user friendly by highlighting matches
# and exclude grepping through .svn folders.
alias grep='grep -I --color=auto --exclude-dir={.git,.svn,CVS}'
alias pgrep='pgrep -a'

alias ag='ag --nogroup'

if test "$OS" = 'Darwin'
  alias df='df -h'
else
  alias df='df -h --total'
end

# Shortcut for using the Kdiff3 tool for svn diffs.
alias svnkdiff3='svn diff --diff-cmd kdiff3'

# Git {{{
alias g='git'
alias ga='git add'
alias gcmsg='git commit -m'

alias glgp='git log --stat --patch'
alias glo='git log --oneline --decorate'
alias glol='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
alias glola='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'
alias glols='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --stat'

alias gl='git pull'
alias gp='git push'
alias gpd='git push --dry-run'
alias gpf='git push --force-with-lease --force-if-includes'
alias 'gpf!'='git push --force'

alias grh='git reset'
alias gru='git reset --'
alias grhh='git reset --hard'
alias grhk='git reset --keep'
alias grhs='git reset --soft'

alias grv='git remote -v'

alias gss='git status -s --show-stash'
alias gsbu='git status --short --branch --untracked-files'

alias gd='git diff --submodule --word-diff'
alias gdss='git diff --submodule --word-diff --staged'
alias glo='git log --graph --oneline --decorate'

if check_command fzf
  alias gb='_fzf_git_branch'
  alias gco='_fzf_git_checkout'

  alias gdz='_fzf_git_diff'
  alias gloz='_fzf_search_git_log'  # need fzf.fish
  alias gssz='_fzf_search_git_status' # ned fzf.fish
end

if check_command lazygit
  alias lg='lazygit'
end
# }}}

# Valgrind aliases
alias mchk='valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes -v'

# Python {{{
alias pipi='pip install --user'
alias pipiu='pip --user --upgrade'

if test "$OS" = 'Darwin'
  alias virtualenv2='virtualenv --python /usr/local/bin/python2 --system-site-packages'
  alias virtualenv3='virtualenv --python /usr/local/bin/python3 --system-site-packages'
else
  alias virtualenv2='virtualenv --python /usr/bin/python2 --system-site-packages'
  alias virtualenv3='virtualenv --python /usr/bin/python3 --system-site-packages'
end

alias venv='python3 -m venv'

# Use 'pip_search' to replace the disabled search functionality of pip.
# See '_pip()' in 'shell/scripts/02-functions.script'
alias pip='_pip'
alias pip3='_pip3'
# }}}

# Vim
if check_command nvim
  alias vi='nvim'
  alias vim='nvim'
  alias v='nvim'
  alias nv='nvim'
end

if check_command lvim
  alias vi='lvim'
  alias vim='lvim'
  alias v='lvim'
  alias nv='lvim'
end

# Maven
alias mvn-no-javadoc='mvn -Dmaven.javadoc.skip=true'
alias mvn-no-test='mvn -Dmaven.test.skip=true'
alias mvns='_mvn_setting_switch'
alias mvnds='_mvnd_setting_switch'

# youtube-dl
alias ytd='youtube-dl --proxy socks5://127.0.0.1:1088 -r 500K'

# K8s
alias ka='kubeadm'
alias kc='kubectl'
alias ke='keadm'
alias k9='k9s'

# Docker {{{
if check_command docker
  alias dilsa='docker image inspect --format "{{.Architecture}}"'
  alias dps='docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}"'
  alias dcpid='docker container inspect --format "{{.State.Pid}}"'
  alias dcfls='docker-fuzzy-container-ls'
  alias difls='docker-fuzzy-image-ls'
  alias dnfls='docker-fuzzy-network-ls'
  alias dcpid='docker-get-pid-by-container-id'
  alias drm='_drm'
  alias drmi='_drmi'
  alias dco='_docker_compose_project'
  alias dcpd='_docker_compose_project_dir'
  alias dcpcd='_docker_compose_change_dir_to_project'
  alias dilsg='_docker_images_group_by_name'
  alias dilsgi='_docker_images_group_by_id'

  alias lzd='lazydocker'
end
# }}}

if check_command batcat
  alias bat='batcat'
end

# Check xclip
if check_command xclip
  alias xc='xclip -selection clipboard'
end

# netprofiler (https://github.com/yusiwen/netprofiler)
if check_command netprofiler
  alias np='netprofiler'
end

# Check localhost port 7890 of Clash
if test "$OS" = 'Windows_NT'
  if check_command netstat
    if netstat -an|grep LISTEN|grep -q 7890
      alias curlp='curl -x http://localhost:7890'
    end
  end 
else
  if check_command netstat
    if netstat -lnt | grep -q 7890
      alias curlp='curl -x http://localhost:7890'
    end 
  end 
end

alias ipa='ip -c a'
alias ipba='ip -br -c a'

if test -e "$HOME/.config/mytmux/tmux.conf"
  alias tmux='tmux -f $HOME/.config/mytmux/tmux.conf'
end

alias m='mvn'

if check_command z
  alias zf="z -t -l |tr -s ' ' |cut -d ' ' -f 2|fzf"
end

# vim: foldmethod=marker :
