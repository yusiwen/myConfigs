#!/bin/sh

CONFIG_SHELL=$HOME/myConfigs/shell

if [ ! "$SHELL" = "/usr/bin/zsh" ]; then
  echo "Current SHELL is not ZSH"
  if [ ! -e /usr/bin/zsh ]; then
    echo "Cannot find ZSH binary, installing ..."
    sudo apt-get install zsh
    if [ "$?" -ne 0 ]; then
      echo "Install ZSH failed, please manually install it."
      exit
    fi
    echo "Install ZSH ... Done."
    echo "Change SHELL to /usr/bin/zsh ..."
    chsh -s /usr/bin/zsh
    echo "Change SHELL to /usr/bin/zsh ... Done."
  fi
fi

ln -sfnv $CONFIG_SHELL/bashrc $HOME/.bashrc
ln -sfnv $CONFIG_SHELL/bash_aliases $HOME/.bash_aliases
ln -sfnv $CONFIG_SHELL/bash_profile $HOME/.bash_profile
ln -sfnv $CONFIG_SHELL/profile $HOME/.profile
ln -sfnv $CONFIG_SHELL/zshrc $HOME/.zshrc
ln -sfnv $CONFIG_SHELL/oh-my-zsh $HOME/.oh-my-zsh
