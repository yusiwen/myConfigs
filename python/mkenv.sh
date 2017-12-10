#!/bin/sh

if ! type pip >/dev/null 2>&1; then
  echo 'Installing pip...'
  sudo apt install python-pip
fi

if ! type pip3 >/dev/null 2>&1; then
  echo 'Installing pip3...'
  sudo apt install python3-pip
fi

mkdir -p $HOME/.pip
ln -sfnv $HOME/myConfig/python/pip.conf $HOME/.pip/pip.conf

if ! type virtualenv >/dev/null 2>&1; then
  echo 'Installing virtualenv...'
  sudo apt install virtualenv
fi
