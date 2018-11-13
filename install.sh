#!/bin/bash

set -e
set -o pipefail

COLOR='\033[0;32m'
COLOR1='\033[1;32m'
NC='\033[0m'

OS=$(uname)
echo -e "${COLOR}Operate System: ${COLOR1}$OS${COLOR} found...${NC}"
if [ -e /etc/os-release ]; then
  DISTRO=$(awk -F= '/^NAME/{print $2}' /etc/os-release | xargs | cut -d ' ' -f1)
else
  DISTRO=$OS
fi
echo -e "${COLOR}Distribution: ${COLOR1}$DISTRO${COLOR} found...${NC}"

function vercomp () { # {{{
  if [[ $1 == $2 ]]; then
    return 0
  fi
  local IFS=.
  local i ver1=($1) ver2=($2)
  # fill empty fields in ver1 with zeros
  for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
    ver1[i]=0
  done
  for ((i=0; i<${#ver1[@]}; i++)); do
    if [[ -z ${ver2[i]} ]]; then
      # fill empty fields in ver2 with zeros
      ver2[i]=0
    fi
    if ((10#${ver1[i]} > 10#${ver2[i]})); then
      return 1
    fi
    if ((10#${ver1[i]} < 10#${ver2[i]})); then
      return 2
    fi
  done
  return 0
} # }}}

# Initialize apt and install prerequisite packages
function init_env() { # {{{
  if [ $OS = 'Linux' ]; then
    if [ $DISTRO = 'Ubuntu' ]; then
      set +e
      MIRRORS=$(grep "mirrors.aliyun.com" /etc/apt/sources.list|wc -l)
      set -e
      if [ $MIRRORS -eq 0 ]; then
        echo -e "${COLOR}Setting Ubuntu apt source to aliyun...${NC}"
        sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
        sudo sed -i "s/^deb http:\/\/.*archive\.ubuntu\.com/deb http:\/\/mirrors\.aliyun\.com/g" /etc/apt/sources.list
        sudo apt update
      fi

      sudo apt install -y curl lua5.3 perl silversearcher-ag p7zip-full
    fi
  elif [ $OS = 'Darwin' ]; then
    if ! type brew >/dev/null 2>&1; then
      echo -e "${COLOR}Installing ${COLOR1}HomeBrew${COLOR}...${NC}"
      # On MacOS ruby is pre-installed already
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
  fi
} # }}}

# GFW
function install_gfw() { # {{{
  if [ $OS = 'Linux' ]; then
    if ! type tsocks >/dev/null 2>&1; then
      echo -e "${COLOR}Installing tsocks...${NC}"
      sudo apt install -y tsocks
    fi

    if ! type pip >/dev/null 2>&1; then
      install_python
    fi

    # Install the latest shadowsocks version to support chahca20-ietf-poly1305 algorithm
    echo -e "${COLOR}Checking shadowsocks command line tools...${NC}"
    sudo apt install -y libsodium-dev
    if ! type sslocal >/dev/null 2>&1; then
      echo -e "${COLOR}Installing shadowsocks command line tools...${NC}"
      sudo -H pip install https://github.com/shadowsocks/shadowsocks/archive/master.zip -U
    fi

    if ! type supervisorctl >/dev/null 2>&1; then
      echo -e "${COLOR}Installing supervisor...${NC}"
      sudo apt install -y supervisor
    fi

    echo -e "${COLOR}Please create config file at ${COLOR1}'/etc/shadowsocks.json'${COLOR} and run '${COLOR1}sslocal${COLOR}'...${NC}"
    echo -e "${COLOR}And use '${COLOR1}supervisor${COLOR}' to start it at bootup${NC}"

    if ! type polipo >/dev/null 2>&1; then
      echo -e "${COLOR}Installing polipo proxy...${NC}"
      sudo apt install -y polipo
    else
      echo -e "${COLOR1}polipo${COLOR} was found.${NC}"
    fi

    if [ -d $HOME/myConfigs ]; then
      ln -sfnv $HOME/myConfigs/gfw/tsocks.conf $HOME/.tsocks.conf
      sudo cp $HOME/myConfigs/gfw/polipo.conf /etc/polipo/config
      sudo systemctl restart polipo

      sudo cp $HOME/myConfigs/gfw/supervisor-shadowsocks.conf /etc/supervisor/conf.d/shadowsocks.conf
    else
      echo -e "${COLOR1}myConfigs${COLOR} was not found, please install git and fetch it from repo, then run 'install.sh gfw' again to link some configuration files.${NC}"
    fi

    echo -e "${COLOR}GFW initialized.${NC}"
  fi
} # }}}

# Git
function install_git() { # {{{
  if [ $OS = 'Linux' ]; then
    if [ $DISTRO = 'Ubuntu' ]; then
      # install git if not exist
      GIT_PPA=/etc/apt/sources.list.d/git-core-ubuntu-ppa-$(lsb_release -c -s).list
      if [ ! -e $GIT_PPA ]; then
        echo -e "${COLOR}Add ${COLOR1}git-core${COLOR} ppa...${NC}"
        sudo apt-add-repository -y ppa:git-core/ppa
        # Replace official launchpad address with reverse proxy from USTC
        sudo sed -i "s/ppa\.launchpad\.net/launchpad\.proxy\.ustclug\.org/g" $GIT_PPA
        echo -e "${COLOR}Add ${COLOR1}git-core${COLOR} ppa...OK${NC}"
        sudo apt update
        sudo apt upgrade
      else
        echo -e "${COLOR1}ppa:git-core/ppa${COLOR} was found.${NC}"
      fi

      if ! type git >/dev/null 2>&1; then
        echo -e "${COLOR}Installing ${COLOR1}git-core${COLOR}...${NC}"
        sudo apt install -y git
        echo -e "${COLOR}Installing ${COLOR1}git-core${COLOR}...OK${NC}"
      else
        echo -e "${COLOR1}git${COLOR} was found.${NC}"
      fi
    else
      echo -e "${COLOR}Distro ${COLOR1}$DISTRO${COLOR} not supported yet${NC}"
      exit 1
    fi
  elif [ $OS = 'Darwin']; then
    brew install git
  else
    echo -e "${COLOR}OS not supported${NC}"
    exit 1
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

  echo -ne "${COLOR1}Set proxies? [y|N]${NC}"
  read result
  if echo "$result" | grep -iq "^[y|Y]$"; then
    if ! type polipo >/dev/null 2>&1; then
      install_gfw
      read -p "Continue? [y|N]${NC}" CONFIRM
      case $CONFIRM in
        [Yy]* ) ;;
        * ) exit;;
      esac
    fi

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
      mkdir -p $HOME/.ssh
      ln -sfnv $HOME/myConfigs/git/ssh_config $HOME/.ssh/config
    fi
  fi

  if [ $OS = 'Linux' ] || [ $OS = 'Darwin' ]; then
    if [ -d $HOME/myConfigs ]; then
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
} # }}}

function install_ruby() { # {{{
  if [ $OS = 'Linux' ]; then
    if [ $DISTRO = 'Ubuntu' ]; then
      if ! type ruby >/dev/null 2>&1; then
        echo -e "${COLOR}Installing ${COLOR1}Ruby${COLOR}...${NC}"
        sudo apt install -y ruby-full curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev libffi-dev
        echo -e "${COLOR}Installing ${COLOR1}Ruby${COLOR}...OK${NC}"
      else
        echo -e "${COLOR1}ruby${COLOR} was found.${NC}"
      fi
    else
      echo -e "${COLOR}Distro ${COLOR1}$DISTRO${COLOR} not supported yet${NC}"
      exit 1
    fi
  elif [ $OS = 'Darwin' ]; then
    if ! type ruby >/dev/null 2>&1; then
      brew install ruby
    else
      echo -e "${COLOR1}ruby${COLOR} was found.${NC}"
    fi
  else
    echo -e "${COLOR}OS not supported${NC}"
    exit 1
  fi

  echo -e "${COLOR}Replace official repo with Ruby-China mirror...${NC}"
  gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
  gem sources -l
  echo -e "${COLOR}Replace official repo with Ruby-China mirror...OK${NC}"

  export PATH="$(ruby -e 'puts Gem.user_dir')/bin:$PATH"
  if ! type bundle >/dev/null 2>&1; then
    echo -e "${COLOR}Installing bundler...${NC}"
    gem install --user-install bundler
    echo -e "${COLOR}Installing bundler...OK${NC}"
  else
    echo -e "${COLOR1}bundler${COLOR} was found.${NC}"
  fi

  echo -e "${COLOR}Configurate bundler to use Ruby-China mirror...${NC}"
  bundle config mirror.https://rubygems.org https://gems.ruby-china.com
  echo -e "${COLOR}Configurate bundler to use Ruby-China mirror...OK${NC}"
} # }}}

# Initialize myConfigs repo
function fetch_myConfigs() { # {{{
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
    sudo systemctl restart polipo
  fi
} # }}}

function install_python() { # {{{
  if [ $OS = 'Linux' ]; then
    IS_PYTHON_NEED_INSTALL=0

    if [ ! type python3 &>/dev/null ]; then
      IS_PYTHON_NEED_INSTALL=1
    else
      PYTHON_VERSION=`python3 -c 'import sys; version=sys.version_info[:3]; print("{0}.{1}.{2}".format(*version))'`
      echo -e "${COLOR}Detect Python3 version: $PYTHON_VERSION${NC}"

      set +e
      vercomp $PYTHON_VERSION 3.6
      if [ $? -eq 2 ]; then
        IS_PYTHON_NEED_INSTALL=1
      fi
      set -e
    fi

    if [ $DISTRO = 'Ubuntu' ]; then
      if [ $IS_PYTHON_NEED_INSTALL -eq 1 ]; then
        echo -e "${COLOR}Python3 is out-dated, update to version 3.6...${NC}"
        PYTHON3_PPA=/etc/apt/sources.list.d/deadsnakes-ubuntu-ppa-$(lsb_release -c -s).list
        sudo add-apt-repository -y ppa:deadsnakes/ppa
        # Replace official launchpad address with reverse proxy from USTC
        sudo sed -i "s/ppa\.launchpad\.net/launchpad\.proxy\.ustclug\.org/g" $PYTHON3_PPA
        sudo apt-get update
        sudo apt-get install -y python3.6
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
      echo "[global]" > $HOME/.pip/pip.conf
      echo "index-url = https://mirrors.ustc.edu.cn/pypi/web/simple" >> $HOME/.pip/pip.conf

      if ! type virtualenv >/dev/null 2>&1; then
        echo -e "${COLOR}Installing ${COLOR1}virtualenv${COLOR}...${NC}"
        sudo apt install -y virtualenv
      fi
    else
      echo -e "${COLOR}Distro ${COLOR1}$DISTRO${COLOR} not supported yet${NC}"
      exit 1
    fi
  elif [ $OS = 'Darwin' ]; then
    if ! type brew >/dev/null 2>&1; then
      init_env
    fi

    # Homebrew's python has pip included
    brew install python

    mkdir -p $HOME/.config/pip
    echo "[global]" > $HOME/.config/pip/pip.conf
    echo "index-url = https://mirrors.ustc.edu.cn/pypi/web/simple" >> $HOME/.config/pip/pip.conf

    pip install virtualenv
  else
    echo -e "${COLOR}OS not supported${NC}"
    exit 1
  fi
} # }}}

function install_node() { # {{{
  if [ ! -d $HOME/myConfigs ]; then
    fetch_myConfigs
  fi

  if ! type node >/dev/null 2>&1; then
    if [ $OS = 'Linux' ]; then
      if [ $DISTRO = 'Ubuntu' ]; then
        NODE_PPA=/etc/apt/sources.list.d/nodesource.list
        echo -e "${COLOR}Installing Node.js v10...${NC}"

        if ! type curl >/dev/null 2>&1; then
          init_env
        fi
        curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -

        echo 'deb https://mirrors.tuna.tsinghua.edu.cn/nodesource/deb_10.x bionic main' | sudo tee  nodesource.list
        echo-src 'deb https://mirrors.tuna.tsinghua.edu.cn/nodesource/deb_10.x bionic main' | sudo tee --append  nodesource.list
	sudo apt update

        echo -e "${COLOR}Installing ${COLOR1}Node.js${COLOR}...${NC}"
        sudo apt install -y nodejs
      fi
    elif [ $OS = 'Darwin' ]; then
      if ! type brew >/dev/null 2>&1; then
        init_env
      fi
      brew install node
    fi
  else
    echo -e "${COLOR1}Node.js($(node -v))${COLOR} was found.${NC}"
  fi

  mkdir -p $HOME/.npm-packages
  if [ ! -e $HOME/.npmrc ]; then
    cp $HOME/myConfigs/node.js/npmrc $HOME/.npmrc
  fi

  npm install -g yarn eslint npm-check npm-check-updates
} # }}}

function install_zsh() { # {{{
  CONFIG_SHELL=$HOME/myConfigs/shell
  if [ ! -d $CONFIG_SHELL ]; then
    fetch_myConfigs
  fi

  if [ ! "$SHELL" = "/usr/bin/zsh" ]; then
    echo -e "${COLOR}Current SHELL is not ${COLOR1}Zsh${NC}"
    if [ ! -e /usr/bin/zsh ]; then
      echo -e "${COLOR}Installing ${COLOR1}Zsh${COLOR}...${NC}"
      sudo apt install -y zsh
      echo -e "${COLOR}Change SHELL to ${COLOR1}Zsh${COLOR}, take effect on next login${NC}"
      chsh -s /usr/bin/zsh
    fi
  fi

  ln -sfnv $CONFIG_SHELL/bashrc $HOME/.bashrc
  ln -sfnv $CONFIG_SHELL/bash_aliases $HOME/.bash_aliases
  ln -sfnv $CONFIG_SHELL/bash_profile $HOME/.bash_profile
  ln -sfnv $CONFIG_SHELL/profile $HOME/.profile
  ln -sfnv $CONFIG_SHELL/zshrc $HOME/.zshrc
  ln -sfnv $CONFIG_SHELL/oh-my-zsh $HOME/.oh-my-zsh
} # }}}

function install_vim() { # {{{
  CONFIG_VIM=$HOME/myConfigs/vim
  VIM_HOME=$HOME/.vim
  VIM_PACKAGE=vim

  if [ ! -d $CONFIG_VIM ]; then
    fetch_myConfigs
  fi

  if [ $OS = 'Linux' ]; then
    if [ $DISTRO = 'Ubuntu' ]; then
      VIM_PPA=/etc/apt/sources.list.d/jonathonf-ubuntu-vim-$(lsb_release -s -c).list
      if [ ! -e $VIM_PPA ]; then
        echo -e "${COLOR}No latest vim ppa found, adding ${COLOR1}ppa:jonathonf/vim${COLOR}...${NC}"
        sudo add-apt-repository -y ppa:jonathonf/vim
        sudo sed -i "s/ppa\.launchpad\.net/launchpad\.proxy\.ustclug\.org/g" $VIM_PPA
        sudo apt update
      else
        echo -e "${COLOR1}ppa:jonathonf/vim${COLOR} was found${NC}"
      fi

      echo -e "${COLOR}Ubuntu is found, checking ${COLOR1}$VIM_PACKAGE${COLOR1}...${NC}"
      # Check if VIM_PACKAGE is installed or not
      set +e
      PACKAGE=$(dpkg -l | grep $VIM_PACKAGE | cut -d ' ' -f 3 | grep ^$VIM_PACKAGE$ | wc -l)
      set -e
      if [ $PACKAGE -eq 0 ]; then
        echo -e "${COLOR1}$VIM_PACKAGE${COLOR} is not found.${NC}"
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
    echo -e "${COLOR}Darwin is found, checking vim...${NC}"
    set +e
    PACKAGE=$(brew list|grep vim)
    set -e
    if [ -z "$PACKAGE" ]; then
      echo -e "${COLOR1}vim${COLOR} is not found. Installing...${NC}"
      brew install vim vim --with-python3
    else
      echo -e "${COLOR1}vim${COLOR} is found.${NC}"
    fi

    echo -e "${COLOR}Install supplementary tools...${NC}"
    brew install ctags the_silver_searcher cscope astyle
  else
    echo -e "${COLOR}Unknown OS, please make sure vim is installed.${NC}"
    exit
  fi

  if [ ! -d "$VIM_HOME" ]; then
    mkdir $VIM_HOME
  fi

  ln -sfnv $CONFIG_VIM/vimrc $VIM_HOME/vimrc
  ln -sfnv $CONFIG_VIM/ftplugin $VIM_HOME/ftplugin
  ln -sfnv $CONFIG_VIM/plugin $VIM_HOME/plugin
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
  ln -sfnv $CONFIG_VIM/spell $VIM_HOME/spell

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
  else
    echo -e "${COLOR1}ppa:neovim-ppa/stable${COLOR} was found${NC}"
  fi

  set +e
  PACKAGE=$(dpkg -l | grep neovim | cut -d ' ' -f 3 | grep ^neovim$ | wc -l)
  set -e
  if [ $PACKAGE -eq 0 ]; then
    echo -e "${COLOR1}NeoVim${COLOR} is not found.${NC}"
    # Install VIM_PACKAGE
    echo -e "${COLOR}Install ${COLOR1}NeoVim${COLOR}...${NC}"
    sudo apt install -y neovim
  else
    echo -e "${COLOR1}NeoVim${COLOR} is found, trying to find latest upgrades...${NC}"
    sudo apt update && sudo apt upgrade
  fi

  ln -sfnv $CONFIG_VIM/init.vim $VIM_HOME/init.vim
  ln -sfnv $CONFIG_VIM/vimrc.neovim $VIM_HOME/vimrc.neovim
  mkdir -p $HOME/.config
  ln -sfnv $HOME/.vim $HOME/.config/nvim

  # Initialize Python 2 & 3 environment for NeoVim
  VARPATH=$HOME/.cache/vim
  mkdir -p $VARPATH/venv

  if ! type virtualenv >/dev/null 2>&1; then
    echo -e "${COLOR}Python environment is not initialized. Initializing now...${NC}"
    install_python
  fi

  # Install python neovim, PyYALM package site widely
  echo -e "${COLOR}Installing python package: neovim, PyYAML...${NC}"
  set +e
  NV_PYTHON_PCK=$(pip list 2>/dev/null | grep neovim | wc -l)
  set -e
  if [ $NV_PYTHON_PCK -eq 0 ]; then
    sudo -H pip2 install neovim
  fi
  set +e
  NV_PYTHON_PCK=$(pip list 2>/dev/null | grep PyYAML | wc -l)
  set -e
  if [ $NV_PYTHON_PCK -eq 0 ]; then
    sudo -H pip install PyYAML
  fi

  if [ ! -d $VARPATH/venv/neovim2 ]; then
    virtualenv --system-site-packages -p /usr/bin/python2 $VARPATH/venv/neovim2
  fi
  if [ ! -d $VARPATH/venv/neovim3 ]; then
    virtualenv --system-site-packages -p /usr/bin/python3 $VARPATH/venv/neovim3
  fi
  echo -e "${COLOR}Initialized python environment for neovim, run ':UpdateRemotePlugin' on first startup"

  # Node.js package for NeoVim
  if ! type npm >/dev/null 2>&1; then
    echo -e "${COLOR1}Node.js${COLOR} environment is not initialized. Initializing now...${NC}"
    install_node
  fi

  set +e
  NV_NODE_PCK=$(npm list --global | grep neovim | wc -l)
  set -e
  if [ $NV_PYTHON_PCK -eq 0 ]; then
    npm install -g neovim
  fi
  #}}}

  npm install -g jshint jsxhint jsonlint stylelint sass-lint raml-cop markdownlint-cli write-good
  pip install --user pycodestyle pyflakes flake8 vim-vint proselint yamllint yapf
} #}}}

function install_rxvt() { # {{{
  if [ $OS = 'Linux' ]; then
    if [ ! -d $HOME/myConfigs ]; then
      fetch_myConfigs
    fi

    if [ -e $HOME/.Xresources ]; then
      cp $HOME/.Xresources $HOME/.Xresources.backup
    fi
    ln -sfnv $HOME/myConfigs/X11/Xresources $HOME/.Xresources
    $HOME/myConfigs/change_font.sh
    $HOME/myConfigs/change_theme.sh
    xrdb -load $HOME/.Xresources

    if [ $DISTRO = 'Ubuntu' ]; then
      if ! type rxvt >/dev/null 2>&1; then
        echo -e "${COLOR}Installing ${COLOR1}rxvt-unicode-256color${COLOR}...${NC}"
        sudo apt install -y rxvt-unicode-256color
      fi
    fi
  else
    echo -e "${COLOR1}rxvt-unicode-256color${COLOR} will only be installed on Linux.${NC}"
  fi
} # }}}

function install_i3wm() { # {{{
  if [ $OS = 'Linux' ]; then
    if [ $DISTRO = 'Ubuntu' ]; then
      # Install i3-gaps if not exist
      if ! type i3 >/dev/null 2>&1; then
        echo -e "${COLOR}Install ${COLOR1}i3${COLOR}...${NC}"
        sudo apt install -y lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings i3 ubuntu-drivers-common mesa-utils mesa-utils-extra compton xorg xserver-xorg hsetroot pcmanfm scrot simplescreenrecorder feh bleachbit
      fi

      sudo apt install libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev autoconf libxcb-xrm0 libxcb-xrm-dev automake
      if [ ! -d ~/git/i3-gaps ]; then
        mkdir -p ~/git
        if ! type git >/dev/null 2>&1; then
          install_git
        fi
        pushd ~/git
        git clone https://github.com/Airblader/i3.git i3-gaps
        cd  ~/git/i3-gaps
        autoreconf --force --install
        rm -rf build/
        mkdir -p build && cd build/
        ../configure --disable-sanitizers
        make
        sudo make install
        popd && popd && popd
      fi

      # Polybar
      sudo apt install cmake cmake-data pkg-config libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev libxcb-randr0-dev libxcb-composite0-dev python-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-xrm-dev libxcb-cursor-dev libjsoncpp-dev libjsoncpp1
      if [ ! -d ~/git/polybar ]; then
        mkdir -p ~/git
        pushd ~/git
        git clone --recursive https://github.com/jaagr/polybar.git
        cd polybar
        mkdir -p build
        cd build
        cmake ..
        sudo make install
        popd && popd && popd
      fi

      CONFIG_HOME=$HOME/myConfigs/i3
      if [ ! -d $CONFIG_HOME ]; then
        fetch_myConfigs
      fi

      I3_HOME=$HOME/.i3
      [ ! -d $I3_HOME ] && mkdir -p $I3_HOME
      ln -sfnv $CONFIG_HOME/_config $I3_HOME/_config
      ln -sfnv $CONFIG_HOME/i3blocks/i3blocks.conf $I3_HOME/i3blocks.conf

      mkdir -p ~/.config/polybar
      ln -sfnv $CONFIG_HOME/polybar.config ~/.config/polybar/config
      ln -sfnv $CONFIG_HOME/compton.conf ~/.config/compton.conf

      DUNST_HOME=$HOME/.config/dunst
      [ ! -d $DUNST_HOME ] && mkdir -p $DUNST_HOME
      ln -sfnv $CONFIG_HOME/dunst/dunstrc $DUNST_HOME/dunstrc

      mkdir -p $HOME/bin
      ln -sfnv $CONFIG_HOME/i3bang/i3bang.rb $HOME/bin/i3bang
      # link default theme 'jellybeans' to ~/.i3/_config.colors
      ln -sfnv $CONFIG_HOME/colors/_config.jellybeans $I3_HOME/config.colors

      # check if 'ruby' is installed or not
      if ! type ruby >/dev/null 2>&1; then
        install_ruby
      fi
      i3bang

      # check if 'consolekit' is installed or not
      #echo -e "${COLOR}Checking ${COLOR1}consolekit${COLOR}...${NC}"
      #set +e
      #CONSOLEKIT_PCK=$(dpkg -l | grep consolekit | wc -l)
      #set -e
      #if [ $CONSOLEKIT_PCK -eq 0 ]; then
      #  # Install 'consolekit'
      #  echo -e "${COLOR}Installing ${COLOR1}consolekit${COLOR}...${NC}"
      #  sudo apt install -y consolekit
      #fi

      # check if 'rofi' is installed or not
      echo -e "${COLOR}Checking ${COLOR1}rofi${COLOR}...${NC}"
      if ! type rofi >/dev/null 2>&1; then
        # Install 'rofi'
        echo -e "${COLOR}Installing ${COLOR1}rofi${COLOR}...${NC}"
        ROFI_PPA=/etc/apt/sources.list.d/jasonpleau-ubuntu-rofi-$(lsb_release -c -s).list
        sudo add-apt-repository -y ppa:jasonpleau/rofi
        # Replace official launchpad address with reverse proxy from USTC
        sudo sed -i "s/ppa\.launchpad\.net/launchpad\.proxy\.ustclug\.org/g" $ROFI_PPA
        sudo apt-get update
        sudo apt-get install -y rofi
      fi
    fi
  else
    echo -e "${COLOR}i3wm will only be installed on Linux.${NC}"
  fi
} # }}}

function install_all() { # {{{
  init_env
  install_python
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
  install_node
  install_zsh
  install_vim
  install_rxvt
  install_i3wm
} # }}}

function print_info() {
  echo -e "\nUsage:\n${COLOR}install.sh [all|gfw|git|i3wm|myConfigs|node|python|ruby|rxvt|vim|zsh]${NC}"
}

case $1 in
  all) install_all;;
  init) init_env;;
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

# vim: fdm=marker
