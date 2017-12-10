#!/bin/sh

. $HOME/myConfigs/gfw/get_apt_proxy.sh $1

if ! type "curl" &> /dev/null; then
  echo 'Installing curl...'
  sudo apt install curl
fi

NODE_PACKAGE=$(dpkg -l|cut -d " " -f 3|grep "nodejs")
if [ -z "$NODE_PACKAGE" ]; then

  echo "[1] Node.js v4"
  echo "[2] Node.js v6"
  echo "[3] Node.js v8"
  echo -n "Choose version[3]:"
  read version

  if [ -z $version ]; then
    version='3'
  fi

  if echo "$version" | grep -iq "^1"; then
    curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
  elif echo "$version" | grep -iq "^2"; then
    curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
  elif echo "$version" | grep -iq "^3"; then
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
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
cp $HOME/myConfigs/node.js/npmrc $HOME/.npmrc

