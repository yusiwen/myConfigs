#!/bin/sh

BASE=$HOME/.local

if [ ! -e $BASE/bin/pip ]; then
  curl -O https://bootstrap.pypa.io/get-pip.py
  python get-pip.py --user
fi
