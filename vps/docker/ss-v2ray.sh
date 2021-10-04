#!/bin/bash

SSPWD=$(awk -F "=" '/SS_PWD/ {print $2}' /root/.my.pwd.cnf)

docker run -d \
  --name ss-v2ray \
  --restart unless-stopped \
  -p 127.0.0.1:1080:1080 \
  -e PASSWD="$SSPWD" \
  harbor.yusiwen.cn/library/ss-v2ray:v3.3.5
