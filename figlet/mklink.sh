#!/bin/sh

# Install 'toilet' package first.
for file in *.flf
do
  fullpath=`readlink -f $file`
  ln -sf $fullpath /usr/share/figlet/$file
done
