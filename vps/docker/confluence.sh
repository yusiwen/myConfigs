#!/bin/bash

docker run -d --name confluence \
  --restart unless-stopped \
  -p 127.0.0.1:8090:8090 \
  -p 127.0.0.1:8091:8091 \
  -v /var/lib/confluence:/var/atlassian/application-data/confluence \
  -e JVM_MAXIMUM_MEMORY=2048m \
  -e ATL_PROXY_NAME=confluence.yusiwen.cn \
  atlassian/confluence-server:latest
