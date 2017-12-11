#!/bin/sh

if ! type docker >/dev/null 2>&1; then
  echo 'Installing docker.io...'
  sudo apt install docker.io
fi

sudo cp daemon.json /etc/docker
sudo systemctl restart docker
