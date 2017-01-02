#!/bin/sh

if [ -d "$HOME/myConfigs" ]; then
  . $HOME/myConfigs/gfw/get_apt_proxy.sh
fi

OS=$(uname)
echo "$OS found..."
if [ $OS = 'Linux' ]; then
  # install git if not exist
  GIT_SOURCE="^deb http://ppa.launchpad.net/git-core/ppa/ubuntu $(lsb_release -c -s) main"
  APT_SOURCE=$(grep "$GIT_SOURCE" /etc/apt/sources.list.d/*.list)
  if [ -z "$APT_SOURCE" ]; then
    echo "Add git-core ppa..."
    sudo apt-add-repository ppa:git-core/ppa
    sudo apt-get $APT_PROXY update
  fi

  if [ -z $(dpkg -l | awk '{print $2}' | grep -e '^git$') ]; then
    sudo apt-get $APT_PROXY install git
  fi
fi

git config --global user.email "yusiwen@gmail.com"
git config --global user.name "Siwen Yu"

if [ ${OS:0:5} = 'MINGW' ]; then
  # On Windows, commit with LF and checkout with CRLF
  git config --global core.autocrlf true
else
  # On Linux or Mac, commit with LF and no change on checkout
  git config --global core.autocrlf input
fi
# Turn on warning on convert EOL failure
git config --global core.safecrlf warn

git config --global core.editor "vim"
git config --global merge.tool vimdiff
git config --global merge.conflictstyle diff3
git config --global mergetool.prompt false

git config --global http.proxy 'http://d.qypac.net:15355'
git config --global https.proxy 'http://d.qypac.net:15355'

if [ $OS = 'Linux' ] || [ $OS = 'Darwin' ]; then
mkdir -p $HOME/.ssh
ln -sfnv $HOME/myConfigs/git/ssh_config $HOME/.ssh/config

mkdir -p $HOME/bin
ln -sfnv $HOME/myConfigs/git/git-migrate $HOME/bin/git-migrate
ln -sfnv $HOME/myConfigs/git/git-new-workdir $HOME/bin/git-new-workdir
fi
