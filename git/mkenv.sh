#!/bin/sh

git config --global user.email "yusiwen@gmail.com"
git config --global user.name "Siwen Yu"

git config --global core.autocrlf input

git config --global core.editor "vim"
git config --global merge.tool vimdiff
git config --global merge.conflictstyle diff3
git config --global mergetool.prompt false

git config --global http.proxy 'http://b.qypac.net:15355'
git config --global https.proxy 'http://b.qypac.net:15355'

mkdir -p $HOME/.ssh
ln -sfnv $HOME/myConfigs/git/ssh_config $HOME/.ssh/config

mkdir -p $HOME/bin
ln -sfnv $HOME/myConfigs/git/git-migrate $HOME/bin/git-migrate
ln -sfnv $HOME/myConfigs/git/git-new-workdir $HOME/bin/git-new-workdir
