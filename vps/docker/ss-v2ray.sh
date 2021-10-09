#!/bin/bash

SSPWD=$(awk -F "=" '/SS_PWD/ {print $2}' /root/.my.pwd.cnf)

docker run -d \
  --name ss-v2ray \
  --restart unless-stopped \
  --network host \
  -e PASSWD="$SSPWD" \
  -v /root/ss-v2ray/config.json:/config.json \
  -v /root/ss-v2ray/fullchain.pem:/fullchain.pem \
  -v /root/ss-v2ray/privkey.pem:/privkey.pem \
  harbor.yusiwen.cn/library/ss-v2ray:v3.3.5-slim
