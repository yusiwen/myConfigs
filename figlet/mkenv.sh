#!/bin/sh

# Install 'toilet' package first.
for file in $HOME/myConfigs/figlet/*.*lf
do
  #fullpath=`readlink -f $file`
  filename=$(basename $file)
  sudo ln -sfnv $file /usr/share/figlet/$filename
done
