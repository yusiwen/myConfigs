#!/bin/bash

docker run -d \
  --restart unless-stopped \
  --name trojan-go \
  --network host \
  -v /root/trojan-go/config.json:/etc/trojan-go/config.json \
  -v /root/trojan-go/fullchain.pem:/etc/trojan-go/fullchain.pem \
  -v /root/trojan-go/privkey.pem:/etc/trojan-go/privkey.pem \
  trojan-go:latest
