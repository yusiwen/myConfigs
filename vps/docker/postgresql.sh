#!/bin/bash

docker run -d \
  --name postgres \
  --restart unless-stopped \
  -p 127.0.0.1:5432:5432 \
  -e POSTGRES_PASSWORD=VCidku4htbCRkbKvVnPh \
  -v /var/lib/postgresql/data:/var/lib/postgresql/data \
  postgres:latest
