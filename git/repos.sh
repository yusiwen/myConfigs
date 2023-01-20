#!/usr/bin/env bash
#
# list clean and/or dirty git repos in the current directory
#
# Author:
# Timm Rebitzki -- bitpals.com
#
# License:
# DAYL. No restrictions -- do as you like.
#
# references:
# https://gist.github.com/trebitzki/e9c57f24a4dfdbd8c1597114f0f5a3e8
# http://stackoverflow.com/questions/3878624/how-do-i-programmatically-determine-if-there-are-uncommited-changes#9393642
#
# usage: repos [-c(lean)] [-d(irty)] [-h(elp)]

script=`basename $0`
usage() { printf "$script: list clean and/or dirty git repositories in current directory\nUsage: $script [-c(lean)] [-d(irty)] [-h(elp)]\n"; exit 1; }

# options

OPT_CLEAN=0	# show clean repos
OPT_DIRTY=0	# show dirty repos

while getopts ":cdh" opt; do
  case "${opt}" in
    c)
      OPT_CLEAN=1
      ;;
    d)
      OPT_DIRTY=1
      ;;
    h)
      usage
      ;;
    *)
      # invalid option
      printf "invalid option $OPTARG\n"
      usage
      ;;
  esac
done
shift $((OPTIND-1))		# shift processed options away

if [[ $OPT_DIRTY -eq 0 &&  $OPT_CLEAN -eq 0 ]]; then
  # no options set; show all repos
  OPT_CLEAN=1
  OPT_DIRTY=1
fi

# find .git dirs, check dirty | clean status, list repos

find `pwd` -name .git -type d -exec dirname {} \; | 
  while read x; do
    shortx=${x#`pwd`/}	# file path without current path prefix
    if [[ -n $(git -C $x status -s) ]]; then
      # repo is dirty
      if [[ $OPT_DIRTY -eq 1 ]]; then echo $shortx; fi
    else
      # repo is clean
      if [[ $OPT_CLEAN -eq 1 ]]; then echo $shortx; fi
    fi
  done

exit 0
