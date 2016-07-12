#!/bin/sh

. $HOME/myConfigs/gfw/get_apt_proxy.sh

# install git if not exist
GIT_SOURCE="^deb http://ppa.launchpad.net/git-core/ppa/ubuntu $(lsb_release -c -s) main"
APT_SOURCE=$(grep "$GIT_SOURCE" /etc/apt/sources.list.d/*.list)
if [ -z "$APT_SOURCE" ]; then
  echo "Add git-core ppa..."
  sudo apt-add-repository ppa:git-core/ppa
  sudo apt-get $APT_PROXY update
  sudo apt-get $APT_PROXY install git
fi

git config --global user.email "yusiwen@gmail.com"
git config --global user.name "Siwen Yu"

git config --global core.autocrlf input

git config --global core.editor "vim"
git config --global merge.tool vimdiff
git config --global merge.conflictstyle diff3
git config --global mergetool.prompt false

git config --global http.proxy 'http://d.qypac.net:15355'
git config --global https.proxy 'http://d.qypac.net:15355'

mkdir -p $HOME/.ssh
ln -sfnv $HOME/myConfigs/git/ssh_config $HOME/.ssh/config

mkdir -p $HOME/bin
ln -sfnv $HOME/myConfigs/git/git-migrate $HOME/bin/git-migrate
ln -sfnv $HOME/myConfigs/git/git-new-workdir $HOME/bin/git-new-workdir
