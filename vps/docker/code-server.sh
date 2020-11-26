#!/bin/bash

docker run -d -p 127.0.0.1:3030:8080 \
  --name code-3.7.3 \
  --restart unless-stopped \
  -v "/var/lib/coder:/home/coder" \
  -v "/var/lib/coder-project:/home/coder/project" \
  -v "/opt/jdk1.8.0_192:/home/coder/jdk1.8.0_192" \
  -v "/opt/apache-maven-3.6.1:/home/coder/apache-maven-3.6.1" \
  -e "DOCKER_USER=coder" \
  codercom/code-server:3.7.3

