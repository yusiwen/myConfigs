#!/bin/sh

. $HOME/myConfigs/gfw/get_apt_proxy.sh

NODE_PACKAGE=$(dpkg -l|cut -d " " -f 3|grep "nodejs")
if [ -z "$NODE_PACKAGE" ]; then

  echo "[1] Node.js v4"
  echo "[1] Node.js v5"
  echo "[1] Node.js v6"
  echo -n "Choose version[1]:"
  read version

  if [ -z $version ]; then
    version='1'
  fi

  if echo "$version" | grep -iq "^1"; then
    curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
  elif echo "$version" | grep -iq "^2"; then
    curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
  elif echo "$version" | grep -iq "^3"; then
    curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
  else
    echo "Nahh!"
    exit
  fi

  echo "Installing Node.js..."
  sudo apt-get $APT_PROXY install -y nodejs
  if [ "$?" -ne 0 ]; then
    echo 'Install Node.js failed, please check your apt-get output.'
    exit 2
  fi
  echo "Installing Node.js...Done."
fi

mkdir -p $HOME/.npm-packages

ln -sfnv $HOME/myConfigs/node.js/npmrc $HOME/.npmrc

echo "Installing cnpm..."
npm install -g cnpm --registry=https://registry.npm.taobao.org

