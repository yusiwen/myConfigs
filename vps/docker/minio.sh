#!/bin/sh

ACCESSKEY=$(head -1 /root/.minio.pwd)
SECRETKEY=$(tail -1 /root/.minio.pwd)

docker run -d -p 127.0.0.1:9000:9000 \
  --name minio \
  -v /data/share:/data \
  -e "MINIO_ACCESS_KEY=$ACCESSKEY" \
  -e "MINIO_SECRET_KEY=$SECRETKEY" \
  minio/minio server /data

