#!/bin/sh

. $HOME/myConfigs/gfw/get_apt_proxy.sh

RUBY_PACKAGE=$(dpkg -l|cut -d " " -f 3|grep "ruby-full")
if [ -z "$RUBY_PACKAGE" ]; then
  echo "Installing Ruby..."
  sudo apt-get $APT_PROXY install ruby-full
  if [ "$?" -ne 0 ]; then
    echo 'Install Ruby failed, please check your apt-get output.'
    exit 2
  fi
  echo "Installing Ruby...Done."
fi

echo "Replace official repo with taobao mirror..."
gem sources --add https://ruby.taobao.org/ --remove https://rubygems.org/
gem sources -l

echo "Installing bundle..."
sudo gem install bundle

echo "Configurate bundler to use taobao mirror..."
bundle config mirror.https://rubygems.org https://ruby.taobao.org
