#!/bin/bash

docker run -d \
  -p 127.0.0.1:3030:8080 \
  --name code \
  --restart unless-stopped \
  --env GOROOT=/usr/local/bin/go \
  --env GOPROXY=https://goproxy.io,direct \
  --env GOPATH=/var/lib/go_packages \
  --env JAVA_HOME=/usr/local/jdk-11.0.10 \
  --env M2_HOME=/usr/local/apache-maven-3.6.3 \
  -v "/var/lib/coder:/home/coder" \
  -v "/var/lib/coder-project:/home/coder/project" \
  -v "/opt/jdk-11.0.10:/usr/local/jdk-11.0.10" \
  -v "/opt/go:/usr/local/bin/go" \
  -v "/opt/go_pkg:/var/lib/go_packages" \
  -v "/opt/apache-maven-3.6.3:/usr/local/apache-maven-3.6.3" \
  codercom/code-server:latest

