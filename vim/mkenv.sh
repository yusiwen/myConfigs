#!/bin/sh

CONFIG_VIM=$HOME/myConfigs/vim
VIM_HOME=$HOME/.vim

# Check if the latest vim ppa is added or not
PPA=$(grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/*.list | grep pi-rho/dev)
if [ -z "$PPA" ]; then
  echo 'Add latest vim ppa ...'
  sudo apt-add-repository ppa:pi-rho/dev
  sudo apt-get update
  sudo apt-get upgrade
  sudo apt-get clean
  echo 'Add latest vim ppa ... done'
fi

# Check if vim-gtk is installed or not
PACKAGE=$(dpkg -l | grep vim-gtk)
if [ -z "$PACKAGE" ]; then
  # Install vim-gtk
  echo 'Install vim-gtk ...'
  sudo apt-get install vim-gtk
  if [ "$?" -ne 0 ]; then
    echo 'Install vim-gtk failed, please check the output of apt-get.'
    exit 1
  fi
  echo 'Install vim-gtk ... done'
fi

ln -sf $CONFIG_VIM/vimrc $HOME/.vimrc

if [ ! -d "$VIM_HOME" ]; then
  mkdir $VIM_HOME
fi

# link custom color themes to $VIM_HOME
if [ ! -L $VIM_HOME/colors ]; then
  ln -sf $CONFIG_VIM/colors $VIM_HOME/colors
fi
# make swap directory to store swap files globally
if [ ! -d $VIM_HOME/swap ]; then
  mkdir $VIM_HOME/swap
fi

if [ ! -d "$VIM_HOME/bundle/Vundle.vim" ]; then
  echo 'Install Vundle.vim ...'
  git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  if [ "$?" -ne 0 ]; then
    echo 'Install Vundle.vim failed, please check your git output.'
    exit 2
  fi
  echo 'Install Vundle.vim ... done'
  echo 'Install vim plugins ...'
  vim +PluginInstall +qall
  echo 'Install vim plugins ... done'
fi
