#!/bin/bash

docker run -it --name upsource-server-instance \
  -v /data/upsource/data:/opt/upsource/data \
  -v /data/upsource/conf:/opt/upsource/conf \
  -v /data/upsource/logs:/opt/upsource/logs \
  -v /data/upsource/backups:/opt/upsource/backups \
  -p 8880:8080 \
  --ulimit memlock=-1:-1 \
  --restart unless-stopped \
  jetbrains/upsource:2019.1.1644
