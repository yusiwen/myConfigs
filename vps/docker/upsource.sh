#!/bin/bash

docker run -d --name upsource-server-instance \
  -v /data/upsource/data:/opt/upsource/data \
  -v /data/upsource/conf:/opt/upsource/conf \
  -v /data/upsource/logs:/opt/upsource/logs \
  -v /data/upsource/backups:/opt/upsource/backups \
  -p 127.0.0.1:8880:8080 \
  --ulimit memlock=-1:-1 \
  --restart unless-stopped \
  jetbrains/upsource:2020.1.1815
