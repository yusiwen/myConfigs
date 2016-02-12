#!/bin/sh

ln -sfnv $HOME/myConfigs/gfw/apt.conf $HOME/.apt.conf
ln -sfnv $HOME/myConfigs/gfw/tsocks.conf $HOME/.tsocks.conf

SS_PACKAGE=$(dpkg -l | cut -d " " -f 3 | grep "shadowsocks-qt5")
if [ -z "$SS_PACKAGE" ]; then
  echo "Installing shadowsocks-qt5..."
  sudo apt-add-repository ppa:hzwhuang/ss-qt5
  sudo apt-get -c ~/.apt.conf update
  sudo apt-get -c ~/.apt.conf install shadowsocks-qt5
  ln -sfnv $HOME/myConfigs/gfw/ss-qt5.config.ini $HOME/.config/shadowsocks-qt5/config.ini
fi
