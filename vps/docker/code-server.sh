#!/bin/bash

docker run -d \
  --network host \
  --name code \
  --restart unless-stopped \
  --env GO111MODULE=on \
  --env GOROOT=/usr/local/bin/go \
  --env GOPROXY=https://goproxy.cn,direct \
  --env GOPATH=/var/lib/go_packages \
  --env JAVA_HOME=/usr/local/jdk17 \
  --env M2_HOME=/usr/local/apache-maven-3.8.4 \
  --env PATH=$GOROOT/bin:$JAVA_HOME/bin:M2_HOME/bin:$PATH \
  -v "/var/lib/coder:/home/coder" \
  -v "/opt/jdk17:/usr/local/jdk17" \
  -v "/opt/jdk11:/usr/local/jdk11" \
  -v "/opt/jdk8:/usr/local/jdk8" \
  -v "/opt/go:/usr/local/bin/go" \
  -v "/opt/go_pkg:/var/lib/go_packages" \
  -v "/opt/apache-maven-3.8.4:/usr/local/apache-maven-3.8.4" \
  codercom/code-server:latest --bind-addr 0.0.0.0:3030

