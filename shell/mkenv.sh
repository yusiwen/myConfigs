#!/bin/sh

CONFIG_SHELL=$HOME/myConfigs/shell

ln -sfnv $CONFIG_SHELL/bashrc $HOME/.bashrc
ln -sfnv $CONFIG_SHELL/bash_aliases $HOME/.bash_aliases
ln -sfnv $CONFIG_SHELL/bash_profile $HOME/.bash_profile
ln -sfnv $CONFIG_SHELL/profile $HOME/.profile
ln -sfnv $CONFIG_SHELL/zshrc $HOME/.zshrc
ln -sfnv $CONFIG_SHELL/oh-my-zsh $HOME/.oh-my-zsh
