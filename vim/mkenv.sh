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
      VIM_PACKAGE=vim-gtk
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
    sudo apt-get $APT_PROXY install exuberant-ctags silversearcher-ag cscope astyle
  fi
elif [ $(uname) = 'Darwin' ]; then
  echo 'Darwin is found, checking vim...'
  PACKAGE=$(brew list|grep vim)
  if [ -z "$PACKAGE" ]; then
    echo 'vim is not found. Installing vim...'
    brew install vim macvim
    echo 'Installing vim...Done.'
  else
    echo 'vim is found.'
  fi

  echo 'Install supplementary tools...'
  brew install ctags the_silver_searcher cscope astyle
else
  echo 'Unknown OS, please make sure vim is installed.'
fi

ln -sfnv $CONFIG_VIM/vimrc $HOME/.vimrc
ln -sfnv $CONFIG_VIM/ctags $HOME/.ctags

if [ ! -d "$VIM_HOME" ]; then
  mkdir $VIM_HOME
fi

# link custom color themes to $VIM_HOME
if [ ! -L $VIM_HOME/colors ]; then
  ln -sfnv $CONFIG_VIM/colors $VIM_HOME/colors
fi
# make swap directory to store swap files globally
if [ ! -d $VIM_HOME/swap ]; then
  mkdir $VIM_HOME/swap
fi

if [ ! -d "$VIM_HOME/bundle/neobundle.vim" ]; then
  echo 'Install neobundle.vim ...'
  git clone git@github.com:Shougo/neobundle.vim.git ~/.vim/bundle/neobundle.vim
  if [ "$?" -ne 0 ]; then
    echo 'Install neobundle.vim failed, please check your git output.'
    exit 2
  fi
  echo 'Install neobundle.vim ... done'
  echo 'Install vim plugins ...'
  ~/.vim/bundle/neobundle.vim/bin/neoinstall
  echo 'Install vim plugins ... done'
  if [ -d $VIM_HOME/bundle/vimproc.vim ]; then
    cd $VIM_HOME/bundle/vimproc.vim && make
    cd $OLDPWD
  fi
fi
