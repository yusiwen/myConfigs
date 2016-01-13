#!/bin/sh

CONFIG_HOME=$HOME/myConfigs/i3

I3_HOME=$HOME/.i3
[ ! -d $I3_HOME ] && mkdir -p $I3_HOME
ln -sfnv $CONFIG_HOME/_config $I3_HOME/_config
ln -sfnv $CONFIG_HOME/i3blocks/i3blocks.conf $I3_HOME/i3blocks.conf

DUNST_HOME=$HOME/.config/dunst
[ ! -d $DUNST_HOME ] && mkdir -p $DUNST_HOME
ln -sfnv $CONFIG_HOME/dunst/dunstrc $DUNST_HOME/dunstrc

mkdir -p $HOME/bin
ln -sfnv $CONFIG_HOME/i3bang/i3bang.rb $HOME/bin/i3bang
i3bang

# check if 'consolekit' is installed or not
PACKAGE=$(dpkg -l | grep consolekit)
if [ -z "$PACKAGE" ]; then
  # Install 'consolekit'
  echo 'Install consolekit...'
  sudo apt-get install consolekit
  if [ "$?" -ne 0  ]; then
    echo 'Install consolekit failed, please check the output of apt-get.'
    exit 1
  fi
  echo 'Install consolekit ... done'
fi

sudo cp $CONFIG_HOME/xsessions/i3.desktop /usr/share/xsessions/i3.desktop
