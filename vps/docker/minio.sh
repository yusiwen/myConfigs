#!/bin/sh

docker run -d -p 127.0.0.1:9000:9000 \
  --name minio \
  -v /data/share:/data \
  -e "MINIO_ACCESS_KEY=B97Q9ZiDWMv4az7RcGfD" \
  -e "MINIO_SECRET_KEY=cQoKNKFNaxibj/6NUVLhM/Lnf2kCGuajoNmRyxDj" \
  minio/minio server /data

