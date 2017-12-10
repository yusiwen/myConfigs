#!/bin/sh

. $HOME/myConfigs/gfw/get_apt_proxy.sh

CONFIG_VIM=$HOME/myConfigs/vim
VIM_HOME=$HOME/.vim
VIM_PACKAGE=

if [ $(uname) = 'Linux' ]; then
  if [ $(lsb_release -i -s) = 'Ubuntu' ]; then
    # Check if ubuntu-server is installed or not
    PACKAGE=$(dpkg -l | grep ubuntu-server)
    if [ ! -z "$PACKAGE" ]; then
      echo 'Ubuntu server edition found.'
      VIM_PACKAGE=vim
    else
      echo 'Ubuntu desktop edition found.'
      if [ -z $DISPLAY ]; then
        echo 'No $DISPLAY found.'
        VIM_PACKAGE=vim
      else
        echo '$DISPLAY found.'
        VIM_PACKAGE=vim-gtk
      fi
    fi

    echo "Ubuntu is found, checking $VIM_PACKAGE..."
    # Check if VIM_PACKAGE is installed or not
    PACKAGE=$(dpkg -l | grep $VIM_PACKAGE)
    if [ -z "$PACKAGE" ]; then
      echo "$VIM_PACKAGE is not found."
      # Install VIM_PACKAGE
      echo "Install $VIM_PACKAGE ..."
      sudo apt-get $APT_PROXY install $VIM_PACKAGE
      if [ "$?" -ne 0 ]; then
        echo "Install $VIM_PACKAGE failed, please check the output of apt-get."
        exit 1
      fi
      echo "Install $VIM_PACKAGE...done"
    else
      echo "$VIM_PACKAGE is found."
    fi

    echo 'Install supplementary tools...'
    sudo apt-get $APT_PROXY install exuberant-ctags silversearcher-ag cscope astyle lua5.3 ruby perl
  fi
elif [ $(uname) = 'Darwin' ]; then
  echo 'Darwin is found, checking vim...'
  PACKAGE=$(brew list|grep vim)
  if [ -z "$PACKAGE" ]; then
    echo 'vim is not found. Installing vim...'
    brew install vim vim --with-python3
    echo 'Installing vim...Done.'
  else
    echo 'vim is found.'
  fi

  echo 'Install supplementary tools...'
  brew install ctags the_silver_searcher cscope astyle
else
  echo 'Unknown OS, please make sure vim is installed.'
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
ln -sfnv $CONFIG_VIM/init.vim $VIM_HOME/init.vim
mkdir -p $HOME/.config
ln -sfnv $HOME/.vim $HOME/.config/nvim

# Initialize Python 2 & 3 environment for NeoVim
VARPATH=$HOME/.cache/vim
mkdir -p $VARPATH/venv

if ! type virtualenv >/dev/null 2>&1; then
  echo 'Python environment is not initialized.'
  echo 'Calling python/mkenv.sh...'
  . $HOME/myConfigs/python/mkenv.sh
fi

pip install -U --user neovim PyYAML
virtualenv --system-site-packages -p /usr/bin/python2 $VARPATH/venv/neovim2
virtualenv --system-site-packages -p /usr/bin/python3 $VARPATH/venv/neovim3
echo 'Initialized env for neovim, run :UpdateRemotePlugin when first startup'

# Node.js package for NeoVim
if ! type npm >/dev/null 2>&1; then
  echo 'Node.js environment is not initialized.'
  echo 'Calling node.js/mkenv.sh'
  . $HOME/myConfigs/node.js/mkenv.sh
fi
npm install -g neovim
#}}}

npm -g install jshint jsxhint jsonlint stylelint sass-lint raml-cop markdownlint-cli write-good
pip install --user pycodestyle pyflakes flake8 vim-vint proselint yamllint

