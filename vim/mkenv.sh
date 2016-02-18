#!/bin/sh

. $HOME/myConfigs/gfw/get_apt_proxy.sh

CONFIG_VIM=$HOME/myConfigs/vim
VIM_HOME=$HOME/.vim

if [ $(uname) = 'Linux' ]; then
  if [ $(lsb_release -i -s) = 'Ubuntu' ]; then
    echo 'Ubuntu is found, checking vim-gtk...'
    # Check if vim-gtk is installed or not
    PACKAGE=$(dpkg -l | grep vim-gtk)
    if [ -z "$PACKAGE" ]; then
      echo 'vim-gtk is not found.'
      # Install vim-gtk
      echo 'Install vim-gtk ...'
      sudo apt-get $APT_PROXY install vim-gtk
      if [ "$?" -ne 0 ]; then
        echo 'Install vim-gtk failed, please check the output of apt-get.'
        exit 1
      fi
      echo 'Install vim-gtk ... done'
    fi
    echo 'vim-gtk is found.'
  fi
elif [ $(uname) = 'Darwin' ]; then
  echo 'Darwin is found, checking vim...'
  PACKAGE=$(brew list|grep vim)
  if [ -z "$PACKAGE" ]; then
    echo 'vim is not found. Installing vim...'
    brew install vim macvim
    echo 'Installing vim...Done.'
  fi
  echo 'vim is found.'
else
  echo 'Unknown OS, please make sure vim is installed.'
fi

ln -sfnv $CONFIG_VIM/vimrc $HOME/.vimrc

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
