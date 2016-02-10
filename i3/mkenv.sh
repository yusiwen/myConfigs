#!/bin/sh

PROXY=""
if [ -e $HOME/apt.conf ]; then
  PROXY="-c $HOME/apt.conf"
fi

# install i3wm if not exist
APT_SOURCE=$(grep debian.sur5r.net /etc/apt/sources.list)
if [ -z "$APT_SOURCE" ]; then
  echo "Adding i3wm official repository to '/etc/apt/sources.list'..."
  echo "deb http://debian.sur5r.net/i3/ $(lsb_release -c -s) universe" | sudo tee --append /etc/apt/sources.list
  echo "Update source..."
  sudo apt-get $PROXY update
  echo "Install i3wm official repository key..."
  sudo apt-get $PROXY --allow-unauthenticated install sur5r-keyring
  sudo apt-get $PROXY update
  echo "Install i3wm..."
  sudo apt-get $PROXY install i3
  echo "Install i3blocks..."
  sudo apt-get $PROXY install i3blocks
fi

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
# link default theme 'jellybeans' to ~/.i3/_config.colors
ln -sfnv $CONFIG_HOME/colors/_config.jellybeans $I3_HOME/_config.colors
i3bang

# check if 'consolekit' is installed or not
echo 'Checking package consolekit...'
dpkg-query -l consolekit 2>/dev/null
if [ "$?" -eq 1 ]; then
  # Install 'consolekit'
  echo 'Install consolekit...'
  sudo apt-get $PROXY install consolekit
  if [ "$?" -ne 0 ]; then
    echo 'Install consolekit failed, please check the output of apt-get.'
    exit 1
  fi
  echo 'Install consolekit ... done'
fi

if [ ! -e /usr/share/xsessions/i3.desktop ]; then
  sudo cp $CONFIG_HOME/xsessions/i3.desktop /usr/share/xsessions/i3.desktop
fi

# xsession autostart files
mkdir -p $HOME/.config/autostart
_files="$CONFIG_HOME/xsessions/autostart/*.desktop"
for file in $_files
do
  _name=`basename $file`
  ln -sfnv $file $HOME/.config/autostart/$_name
done

# check if 'dex' is installed or not, it's needed to load xsession files
echo 'Checking package dex...'
dpkg-query -l dex 2>/dev/null
if [ "$?" -eq 1 ]; then
  # Install 'dex'
  echo 'Install dex...'
  sudo apt-get $PROXY install dex
  if [ "$?" -ne 0 ]; then
    echo 'Install dex failed, please check the output of apt-get.'
    exit 1
  fi
  echo 'Install dex ... done'
fi

