#!/bin/sh

. $HOME/myConfigs/gfw/get_apt_proxy.sh

NODE_PACKAGE=$(dpkg -l|cut -d " " -f 3|grep "nodejs")
if [ -z "$NODE_PACKAGE" ]; then
  echo "Installing node.js 5.x..."
  curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
  sudo apt-get $APT_PROXY install -y nodejs
  if [ "$?" -ne 0 ]; then
    echo 'Install node.js failed, please check your git output.'
    exit 2
  fi
  echo "Installing node.js 5.x...Done."
fi

mkdir -p $HOME/.npm-packages

ln -sfnv $HOME/myConfigs/node.js/npmrc $HOME/.npmrc

