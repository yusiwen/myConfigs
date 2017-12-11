#!/bin/bash

if [[ ( -z $M2_HOME ) && ( ! -d $HOME/maven ) ]]; then
  mkdir -p $HOME/maven
  curl -o $HOME/maven/apache-maven-3.5.2-bin.zip -O "https://mirrors.cnnic.cn/apache/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.zip"
  unzip $HOME/maven/apache-maven-3.5.2-bin.zip -d $HOME/maven
  export M2_HOME=$HOME/maven/apache-maven-3.5.2
  export M2=$M2_HOME/bin
  export MAVEN_OPTS="-Xms64m -Xmx256m"
  export PATH=$PATH:$M2
fi

mkdir -p $HOME/.m2

if ! type git >/dev/null 2>&1; then
  echo 'Git environment is not initialized...'
  echo 'Calling git/mkenv.sh...'
  . $HOME/myConfigs/git/mkenv.sh
fi

if [[ ( -z $M2_REPO ) && ( ! -d $HOME/maven/repository ) ]]; then
  echo 'Fetching maven repository from git.yusiwen.cc...'
  git clone git@git.yusiwen.cc:yusiwen/maven-repo.git $HOME/maven/repository
  export M2_REPO=$HOME/maven/repository
fi

cp $HOME/myConfigs/maven/settings.xml $HOME/.m2/settings.xml

read -p "Input user name for remote maven repository center:" USERNAME
read -p "Input password:" PASSWORD

sed -i "s/USERNAME/$USERNAME/g" $HOME/.m2/settings.xml
sed -i "s/ENCODED_PASSWORD/$PASSWORD/g" $HOME/.m2/settings.xml
