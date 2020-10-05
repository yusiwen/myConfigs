#!/bin/bash

docker run -d \
  --name clash-client \
  --restart unless-stopped \
  -p 7890:7890 \
  -p 7891:7891 \
  -p 7892:7892 \
  -p 9092:9090 \
  -v /etc/clash/config.yaml:/root/.config/clash/config.yaml \
  harbor.yusiwen.cn/library/clash-client:latest

