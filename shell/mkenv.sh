#!/bin/sh

CONFIG_SHELL=$HOME/myConfigs/shell

ln -sf $CONFIG_SHELL/bashrc $HOME/.bashrc
ln -sf $CONFIG_SHELL/bash_aliases $HOME/.bash_aliases
ln -sf $CONFIG_SHELL/bash_profile $HOME/.bash_profile
ln -sf $CONFIG_SHELL/profile $HOME/.profile
ln -sf $CONFIG_SHELL/zshrc $HOME/.zshrc
ln -sf $CONFIG_SHELL/oh-my-zsh $HOME/.oh-my-zsh
