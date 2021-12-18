#!/bin/sh

ACCESSKEY=$(awk -F "=" '/MINIO_AK/ {print $2}' /root/.my.pwd.cnf)
SECRETKEY=$(awk -F "=" '/MINIO_SK/ {print $2}' /root/.my.pwd.cnf)

docker run -d \
  -p 127.0.0.1:9000:9000 \
  --name minio \
  --restart unless-stopped \
  -v /data/share:/data \
  -e "MINIO_ACCESS_KEY=$ACCESSKEY" \
  -e "MINIO_SECRET_KEY=$SECRETKEY" \
  bitnami/minio:2021.6.17
