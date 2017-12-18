#!/bin/bash
set -e
set -o pipefail

COLOR='\033[0;32m'
COLOR1='\033[1;32m'
NC='\033[0m'

OS=$(uname)
echo -e "${COLOR1}$OS${COLOR} found...${NC}"

# Initialize apt and install prerequisite packages
function init_env() {
  if [ $OS = 'Linux' ]; then
    MIRRORS=$(grep "mirrors.aliyun.com" /etc/apt/sources.list|wc -l)
    if [ $MIRRORS -eq 0 ]; then
      sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
      sudo sed -i "^deb http:\/\/.*\.ubuntu\.com/deb http:\/\/mirrors\.aliyun\.com/g" /etc/apt/sources.list
      sudo apt update
    fi

    sudo apt install -y curl lua5.3 perl 
  elif [ $OS = 'Darwin' ]; then
    if ! type brew >/dev/null 2>&1; then
      echo -e "${COLOR}Installing ${COLOR1}HomeBrew${COLOR}...${NC}"
      # On MacOS ruby is pre-installed already
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
  fi
}

# GFW
function install_gfw() {
  if [ $OS = 'Linux' ]; then
    if ! type tsocks >/dev/null 2>&1; then
      echo -e "${COLOR}Installing tsocks...${NC}"
      sudo apt install -y tsocks
    fi

    if ! type ss-qt5 >/dev/null 2>&1; then
      SS_PPA=/etc/apt/sources.list.d/hzwhuang-ubuntu-ss-qt5-$(lsb_release -c -s).list
      if [ ! -e $SS_PPA ]; then
        echo -e "${COLOR}Add ${COLOR1}ss-qt5${COLOR} ppa...${NC}"
        sudo apt-add-repository -y ppa:hzwhuang/ss-qt5
        # Replace official launchpad address with reverse proxy from USTC
        sudo sed -i "s/ppa\.launchpad\.net/launchpad\.proxy\.ustclug\.org/g" $SS_PPA
        sudo apt update
      fi

      echo -e "${COLOR}Installing ${COLOR1}ss-qt5${COLOR}...${NC}"
      sudo apt install -y shadowsocks-qt5
    else
      echo -e "${COLOR1}ss-qt5${COLOR} was found.${NC}"
    fi

    if ! type polipo >/dev/null 2>&1; then
      echo -e "${COLOR}Installing polipo proxy...${NC}"
      sudo apt install -y polipo
    else
      echo -e "${COLOR1}polipo${COLOR} was found.${NC}"
    fi

    if [ -d $HOME/myConfigs ]; then
      ln -sfnv $HOME/myConfigs/gfw/tsocks.conf $HOME/.tsocks.conf
      sudo cp $HOME/myConfigs/gfw/polipo.conf /etc/polipo/config
    else
      echo -e "${COLOR1}myConfigs${COLOR} was not found, please install git and fetch it from repo, then run 'install.sh gfw' again to link some configuration files.${NC}"
    fi

    echo -e "${COLOR}GFW initialized.${NC}"
    echo -e "${COLOR}Please run '${COLOR1}ss-qt5${COLOR}' and configure some shadowsocks server...${NC}"
  fi
}

# Git
function install_git() {
  if [ $OS = 'Linux' ]; then
    # install git if not exist
    GIT_PPA=/etc/apt/sources.list.d/git-core-ubuntu-ppa-$(lsb_release -c -s).list
    if [ ! -e $GIT_PPA ]; then
      echo -e "${COLOR}Add ${COLOR1}git-core${COLOR} ppa...${NC}"
      sudo apt-add-repository -y ppa:git-core/ppa
      # Replace official launchpad address with reverse proxy from USTC
      sudo sed -i "s/ppa\.launchpad\.net/launchpad\.proxy\.ustclug\.org/g" $GIT_PPA
      sudo apt update
    else
      echo -e "${COLOR1}ppa:git-core/ppa${COLOR} was found.${NC}"
    fi

    if ! type git >/dev/null 2>&1; then
      echo -e "${COLOR}Installing ${COLOR1}git-core${COLOR}...${NC}"
      sudo apt install -y git
    else
      echo -e "${COLOR1}git${COLOR} was found.${NC}"
    fi
  elif [ $OS = 'Darwin']; then
    brew install git
  fi

  echo -e "${COLOR}Configuring...${NC}"
  echo -e "${COLOR}Setting 'user.email' to 'yusiwen@gmail.com'${NC}"
  git config --global user.email "yusiwen@gmail.com"

  echo -e "${COLOR}Setting 'user.name' to 'Siwen Yu'${NC}"
  git config --global user.name "Siwen Yu"

  echo -e "${COLOR}Setting line feed behavior...${NC}"
  if [[ $OS = MINGW* ]]; then
    # On Windows, commit with LF and checkout with CRLF
    git config --global core.autocrlf true
  else
    # On Linux or Mac, commit with LF and no change on checkout
    git config --global core.autocrlf input
  fi
  # Turn on warning on convert EOL failure
  git config --global core.safecrlf warn
  
  echo -e "${COLOR}Setting misc...${NC}"
  git config --global core.editor vim
  git config --global merge.tool vimdiff
  git config --global merge.conflictstyle diff3
  git config --global mergetool.prompt false

  echo -e "${COLOR}Setting proxies...${NC}"
  if [ $OS = 'Linux' ]; then
    # On Ubuntu, use polipo as http(s) proxy
    git config --global http.proxy 'http://127.0.0.1:15355'
    git config --global https.proxy 'http://127.0.0.1:15355'
  elif [ $OS = 'Darwin' ]; then
    git config --global http.proxy 'http://127.0.0.1:1087'
    git config --global https.proxy 'http://127.0.0.1:1087'
  else
    git config --global http.proxy 'http://127.0.0.1:1088'
    git config --global https.proxy 'http://127.0.0.1:1088'
  fi

  if [ $OS = 'Linux' ] || [ $OS = 'Darwin' ]; then
    if [ -d $HOME/myConfigs ]; then
      mkdir -p $HOME/.ssh
      ln -sfnv $HOME/myConfigs/git/ssh_config $HOME/.ssh/config

      mkdir -p $HOME/bin
      ln -sfnv $HOME/myConfigs/git/git-migrate $HOME/bin/git-migrate
      ln -sfnv $HOME/myConfigs/git/git-new-workdir $HOME/bin/git-new-workdir
    else
      echo -e "${COLOR1}myConfigs${COLOR} was not found, please install git and fetch it from repo, then run 'install.sh git' again to link some configuration files.${NC}"
    fi
  fi

  if [ -e $HOME/.ssh/id_rsa.pub ]; then
    echo -e "${COLOR1}.ssh/id_rsa.pub${COLOR} was found, please add it to GitHub, BitBucket, GitLab and Gitea${NC}"
    cat $HOME/.ssh/id_rsa.pub
  else
    echo -e "${COLOR1}.ssh/id_rsa.pub${COLOR} was not found, generating it now...${NC}"
    ssh-keygen
    echo -e "${COLOR}Please add it to GitHub, BitBucket, Gitlab and Gitea"
    cat $HOME/.ssh/id_rsa.pub
  fi
}

function install_ruby() {
  if [ $OS = 'Linux' ]; then
    if ! type ruby >/dev/null 2>&1; then
      echo -e "${COLOR}Installing ${COLOR1}Ruby${COLOR}...${NC}"
      sudo apt install -y ruby-full curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev
    else
      echo -e "${COLOR1}ruby${COLOR} was found.${NC}"
    fi
  fi

  echo -e "${COLOR}Replace official repo with taobao mirror...${NC}"
  gem sources --add https://ruby.taobao.org/ --remove https://rubygems.org/
  gem sources -l

  echo -e "${COLOR}Installing bundler...${NC}"
  sudo gem install bundler

  echo -e "${COLOR}Configurate bundler to use taobao mirror...${NC}"
  bundle config mirror.https://rubygems.org https://ruby.taobao.org
}

# Initialize myConfigs repo
function fetch_myConfigs() {
  if ! type git >/dev/null 2>&1; then
    install_git
  fi

  mkdir -p $HOME/git
  if [ -d $HOME/git/myConfigs ]; then
    echo -e "${COLOR1}git/myConfigs${COLOR} already exists.${NC}"
  else
    echo -e "${COLOR}Fetch myConfigs...${NC}"
    git clone git@git.yusiwen.cc:yusiwen/myConfigs.git $HOME/git/myConfigs

    CURDIR=$(pwd)
    cd $HOME/git/myConfigs
    git submodule init
    git submodule update
    cd $CURDIR
  fi
  ln -sfnv $HOME/git/myConfigs $HOME/myConfigs

  if [ $OS = 'Linux' ] || [ $OS = 'Darwin' ]; then
    mkdir -p $HOME/.ssh
    ln -sfnv $HOME/myConfigs/git/ssh_config $HOME/.ssh/config

    mkdir -p $HOME/bin
    ln -sfnv $HOME/myConfigs/git/git-migrate $HOME/bin/git-migrate
    ln -sfnv $HOME/myConfigs/git/git-new-workdir $HOME/bin/git-new-workdir
  fi

  if [ $OS = 'Linux' ]; then
    ln -sfnv $HOME/myConfigs/gfw/tsocks.conf $HOME/.tsocks.conf
    sudo cp $HOME/myConfigs/gfw/polipo.conf /etc/polipo/config
  fi
}

# Python
function install_python() {
  if [ ! -d $HOME/myConfigs ]; then
    fetch_myConfigs
  fi

  if ! type pip >/dev/null 2>&1; then
    echo -e "${COLOR}Installing ${COLOR1}pip${COLOR}...${NC}"
    sudo apt install -y python-pip
  fi
  
  if ! type pip3 >/dev/null 2>&1; then
    echo -e "${COLOR}Installing ${COLOR1}pip3${COLOR}...${NC}"
    sudo apt install -y python3-pip
  fi
  
  mkdir -p $HOME/.pip
  ln -sfnv $HOME/myConfig/python/pip.conf $HOME/.pip/pip.conf
  
  if ! type virtualenv >/dev/null 2>&1; then
    echo -e "${COLOR}Installing ${COLOR1}virtualenv${COLOR}...${NC}"
    sudo apt install -y virtualenv
  fi
}

# Node.js
function install_node() {
  if ! type curl >/dev/null 2>&1; then
    echo -e "${COLOR}Installing ${COLOR1}curl${COLOR}...${NC}"
    sudo apt install -y curl
  fi
  
  if ! type node >/dev/null 2>&1; then
    echo "[1] Node.js v4"
    echo "[2] Node.js v6"
    echo "[3] Node.js v8"
    echo -n "Choose version[3]:"
    read version
  
    if [ -z $version ]; then
      version='3'
    fi
  
    if echo -e "$version" | grep -iq "^1"; then
      curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
    elif echo -e "$version" | grep -iq "^2"; then
      curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
    elif echo -e "$version" | grep -iq "^3"; then
      curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    else
      echo "Nahh!"
      exit
    fi
  
    echo -e "${COLOR}Installing ${COLOR1}Node.js${COLOR}...${NC}"
    sudo apt install -y nodejs
  else
    echo -e "${COLOR1}Node.js${COLOR} was found.${NC}"
  fi
  
  mkdir -p $HOME/.npm-packages
  if [ ! -e $HOME/.npmrc ]; then
    cp $HOME/myConfigs/node.js/npmrc $HOME/.npmrc
  fi
}

function install_zsh() {
  CONFIG_SHELL=$HOME/myConfigs/shell
  if [ ! -d $CONFIG_SHELL ]; then
    fetch_myConfigs
  fi
  
  if [ ! "$SHELL" = "/usr/bin/zsh" ]; then
    echo -e "${COLOR}Current SHELL is not ${COLOR1}ZSH${NC}"
    if [ ! -e /usr/bin/zsh ]; then
      echo -e "${COLOR}Installing ${COLOR1}ZSH${COLOR}...${NC}"
      sudo apt install -y zsh
      echo -e "${COLOR}Change SHELL to /usr/bin/zsh ...${NC}"
      chsh -s /usr/bin/zsh
    fi
  fi
  
  ln -sfnv $CONFIG_SHELL/bashrc $HOME/.bashrc
  ln -sfnv $CONFIG_SHELL/bash_aliases $HOME/.bash_aliases
  ln -sfnv $CONFIG_SHELL/bash_profile $HOME/.bash_profile
  ln -sfnv $CONFIG_SHELL/profile $HOME/.profile
  ln -sfnv $CONFIG_SHELL/zshrc $HOME/.zshrc
  ln -sfnv $CONFIG_SHELL/oh-my-zsh $HOME/.oh-my-zsh
}

function install_vim() {
  CONFIG_VIM=$HOME/myConfigs/vim
  VIM_HOME=$HOME/.vim
  VIM_PACKAGE=

  if [ ! -d $CONFIG_VIM ]; then
    fetch_myConfigs
  fi
  
  if [ $(uname) = 'Linux' ]; then
    if [ $(lsb_release -i -s) = 'Ubuntu' ]; then
      # Check if ubuntu-server is installed or not
      PACKAGE=$(dpkg -l | grep ubuntu-server)
      if [ ! -z "$PACKAGE" ]; then
        echo -e "${COLOR}Ubuntu server edition found.${NC}"
        VIM_PACKAGE=vim
      else
        echo -e "${COLOR}Ubuntu desktop edition found.${NC}"
        if [ -z $DISPLAY ]; then
          echo -e "${COLOR}No DISPLAY found.${NC}"
          VIM_PACKAGE=vim
        else
          echo -e "${COLOR}DISPLAY found.${NC}"
          VIM_PACKAGE=vim-gtk
        fi
      fi
  
      VIM_PPA=/etc/apt/sources.list.d/jonathonf-ubuntu-vim-$(lsb_release -s -c).list
      if [ ! -e $VIM_PPA ]; then
        echo -e "${COLOR}No latest vim ppa found, adding ${COLOR1}ppa:jonathonf/vim${COLOR}...${NC}"
        sudo add-apt-repository -y ppa:jonathonf/vim
        sudo sed -i "s/ppa\.launchpad\.net/launchpad\.proxy\.ustclug\.org/g" $VIM_PPA 
        sudo apt update
      fi
  
      echo -e "${COLOR}Ubuntu is found, checking ${COLOR1}$VIM_PACKAGE${COLOR1}...${NC}"
      # Check if VIM_PACKAGE is installed or not
      PACKAGE=$(dpkg -l | grep $VIM_PACKAGE)
      if [ -z "$PACKAGE" ]; then
        echo -e "$VIM_PACKAGE is not found."
        # Install VIM_PACKAGE
        echo -e "${COLOR}Install ${COLOR1}$VIM_PACKAGE${COLOR}...${NC}"
        sudo apt install -y $VIM_PACKAGE
      else
        echo -e "${COLOR1}$VIM_PACKAGE${COLOR} is found, trying to find latest upgrades...${NC}"
        sudo apt update && sudo apt upgrade
      fi
  
      echo -e "${COLOR}Install supplementary tools...${NC}"
      sudo apt install -y exuberant-ctags silversearcher-ag cscope astyle lua5.3 ruby perl
    fi
  elif [ $(uname) = 'Darwin' ]; then
    echo -e 'Darwin is found, checking vim...'
    PACKAGE=$(brew list|grep vim)
    if [ -z "$PACKAGE" ]; then
      echo -e 'vim is not found. Installing vim...'
      brew install vim vim --with-python3
      echo -e 'Installing vim...Done.'
    else
      echo -e 'vim is found.'
    fi
  
    echo -e 'Install supplementary tools...'
    brew install ctags the_silver_searcher cscope astyle
  else
    echo -e 'Unknown OS, please make sure vim is installed.'
  fi
  
  if [ ! -d "$VIM_HOME" ]; then
    mkdir $VIM_HOME
  fi
  
  ln -sfnv $CONFIG_VIM/vimrc $VIM_HOME/vimrc
  ln -sfnv $CONFIG_VIM/plugins.yaml $VIM_HOME/plugins.yaml
  ln -sfnv $CONFIG_VIM/vimrc.filetype $VIM_HOME/vimrc.filetype
  ln -sfnv $CONFIG_VIM/vimrc.mappings $VIM_HOME/vimrc.mappings
  ln -sfnv $CONFIG_VIM/vimrc.neocomplete $VIM_HOME/vimrc.neocomplete
  ln -sfnv $CONFIG_VIM/vimrc.deoplete $VIM_HOME/vimrc.deoplete
  ln -sfnv $CONFIG_VIM/vimrc.denite $VIM_HOME/vimrc.denite
  ln -sfnv $CONFIG_VIM/vimrc.denite.menu $VIM_HOME/vimrc.denite.menu
  ln -sfnv $CONFIG_VIM/vimrc.nerdtree $VIM_HOME/vimrc.nerdtree
  ln -sfnv $CONFIG_VIM/vimrc.theme $VIM_HOME/vimrc.theme
  ln -sfnv $CONFIG_VIM/ctags $HOME/.ctags
  
  #Default theme
  ln -sfnv $CONFIG_VIM/themes/vimrc.theme.sourcerer $HOME/.vim/vimrc.colortheme
  
  # link custom color themes to $VIM_HOME
  if [ ! -L $VIM_HOME/colors ]; then
    ln -sfnv $CONFIG_VIM/colors $VIM_HOME/colors
  fi
  
  # link snippets to $VIM_HOME
  if [ ! -L $VIM_HOME/snippets ]; then
    ln -sfnv $CONFIG_VIM/snippets $VIM_HOME/snippets
  fi
  
  # NeoVim {{{
  NVIM_PPA=/etc/apt/sources.list.d/neovim-ppa-ubuntu-stable-$(lsb_release -s -c).list
  if [ ! -e $NVIM_PPA ]; then
    echo -e "${COLOR}No latest NeoVim ppa found, adding ${COLOR1}ppa:neovim-ppa/stable${COLOR}...${NC}"
    sudo add-apt-repository -y ppa:neovim-ppa/stable
    sudo sed -i "s/ppa\.launchpad\.net/launchpad\.proxy\.ustclug\.org/g" $NVIM_PPA 
    sudo apt update
  fi

  ln -sfnv $CONFIG_VIM/init.vim $VIM_HOME/init.vim
  mkdir -p $HOME/.config
  ln -sfnv $HOME/.vim $HOME/.config/nvim
  
  # Initialize Python 2 & 3 environment for NeoVim
  VARPATH=$HOME/.cache/vim
  mkdir -p $VARPATH/venv
  
  if ! type virtualenv >/dev/null 2>&1; then
    echo -e 'Python environment is not initialized. Initializing now...'
    install_python
  fi
  
  pip install -U --user neovim PyYAML
  virtualenv --system-site-packages -p /usr/bin/python2 $VARPATH/venv/neovim2
  virtualenv --system-site-packages -p /usr/bin/python3 $VARPATH/venv/neovim3
  echo -e 'Initialized env for neovim, run :UpdateRemotePlugin when first startup'
  
  # Node.js package for NeoVim
  if ! type npm >/dev/null 2>&1; then
    echo -e 'Node.js environment is not initialized.'
    echo -e 'Calling node.js/mkenv.sh'
    . $HOME/myConfigs/node.js/mkenv.sh
  fi
  npm install -g neovim
  #}}}
  
  npm -g install jshint jsxhint jsonlint stylelint sass-lint raml-cop markdownlint-cli write-good
  pip install --user pycodestyle pyflakes flake8 vim-vint proselint yamllint
}

function install_rxvt() {
  if [ $OS = 'Linux' ]; then
    if [ ! -d $HOME/myConfigs ]; then
      fetch_myConfigs
    fi

    ln -sfnv $HOME/myConfigs/X11/Xresources $HOME/.Xresources
    # Default color theme, using ../change_theme.sh to change themes
    ln -sfnv $HOME/myConfigs/X11/themes/jellybeans.xresources $HOME/.Xresources.theme
    # Default font, using ../change_font.sh to change fonts
    ln -sfnv $HOME/myConfigs/X11/fonts/input-mono-compressed.xresources $HOME/.Xresources.font
    xrdb -load $HOME/.Xresources
    
    RXVT_PACAKGE=$(dpkg -l|cut -d " " -f 3|grep "rxvt-unicode-256color")
    if [ -z "$RXVT_PACAKGE" ]; then
      echo -e "Installing rxvt-unicode-256color..."
      sudo apt install -y rxvt-unicode-256color
    fi
  else
    echo -e "${COLOR}rxvt-unicode-256color will only be installed on Linux.${NC}"
  fi
}

# i3wm
function install_i3wm() {
  if [ $OS = 'Linux' ]; then
    # Install i3wm if not exist
    APT_SOURCE=$(grep debian.sur5r.net /etc/apt/sources.list)
    if [ -z "$APT_SOURCE" ]; then
      echo -e "Adding i3wm official repository to '/etc/apt/sources.list'..."
      echo -e "deb http://debian.sur5r.net/i3/ $(lsb_release -c -s) universe" | sudo tee --append /etc/apt/sources.list
      echo -e "Update source..."
      sudo apt update
      echo -e "Install i3wm official repository key..."
      sudo apt --allow-unauthenticated install -y sur5r-keyring
      sudo apt update
    fi

    I3_PACKAGE=$(dpkg -l|cut -d " " -f 3|grep "^i3$")
    if [ -z "$I3_PACKAGE" ]; then
      echo -e "Install i3wm..."
      sudo apt install -y i3
      echo -e "Install i3blocks..."
      sudo apt install -y i3blocks
    else
      sudo apt update && sudo apt upgrade
    fi
  
    CONFIG_HOME=$HOME/myConfigs/i3
    if [ ! -d $CONFIG_HOME ]; then
      fetch_myConfigs
    fi

    I3_HOME=$HOME/.i3
    [ ! -d $I3_HOME ] && mkdir -p $I3_HOME
    ln -sfnv $CONFIG_HOME/_config $I3_HOME/_config
    ln -sfnv $CONFIG_HOME/i3blocks/i3blocks.conf $I3_HOME/i3blocks.conf
  
    DUNST_HOME=$HOME/.config/dunst
    [ ! -d $DUNST_HOME ] && mkdir -p $DUNST_HOME
    ln -sfnv $CONFIG_HOME/dunst/dunstrc $DUNST_HOME/dunstrc
  
    mkdir -p $HOME/bin
    ln -sfnv $CONFIG_HOME/i3bang/i3bang.rb $HOME/bin/i3bang
    # link default theme 'jellybeans' to ~/.i3/_config.colors
    ln -sfnv $CONFIG_HOME/colors/_config.jellybeans $I3_HOME/_config.colors

    # check if 'ruby' is installed or not
    if ! type ruby >/dev/null 2>&1; then
      install_ruby
    fi
    i3bang
  
    # check if 'consolekit' is installed or not
    echo -e 'Checking package consolekit...'
    dpkg-query -l consolekit 2>/dev/null
    if [ "$?" -eq 1 ]; then
      # Install 'consolekit'
      echo -e 'Installing consolekit...'
      sudo apt install -y consolekit
    fi
  
    if [ ! -e /usr/share/xsessions/i3.desktop ]; then
      sudo cp $CONFIG_HOME/xsessions/i3.desktop /usr/share/xsessions/i3.desktop
    fi
  
    # xsession autostart files
    mkdir -p $HOME/.config/autostart
    _files="$CONFIG_HOME/xsessions/autostart/*.desktop"
    for file in $_files
    do
      _name=`basename $file`
      ln -sfnv $file $HOME/.config/autostart/$_name
    done
  
    # check if 'dex' is installed or not, it's needed to load xsession files
    echo -e 'Checking package dex...'
    dpkg-query -l dex 2>/dev/null
    if [ "$?" -eq 1 ]; then
      # Install 'dex'
      echo -e 'Installing dex...'
      sudo apt install -y dex
    fi
  else
    echo -e "${COLOR}i3wm will only be installed on Linux.${NC}"
  fi
}

function install_all() {
  init_env
  install_gfw
  read -p "Continue? [y|N]${NC}" CONFIRM
  case $CONFIRM in
    [Yy]* ) ;;
    * ) exit;;
  esac
  install_git
  read -p "Continue? [y|N]${NC}" CONFIRM
  case $CONFIRM in
    [Yy]* ) ;;
    * ) exit;;
  esac
  fetch_myConfigs
  install_ruby
  install_python
  install_node
  install_zsh
  install_vim
  install_rxvt
  install_i3wm
}

function print_info() {
  echo -e "${COLOR}install.sh [all|gfw|git|myConfigs]${NC}"
}

case $1 in
  all) install_all;;
  gfw) install_gfw;;
  git) install_git;;
  ruby) install_ruby;;
  myConfigs) fetch_myConfigs;;
  python) install_python;;
  node) install_node;;
  zsh) install_zsh;;
  vim) install_vim;;
  rxvt) install_rxvt;;
  i3wm) install_i3wm;;
  *) print_info;;
esac

