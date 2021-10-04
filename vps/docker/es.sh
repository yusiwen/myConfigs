#!/bin/bash

docker run -d \
  --name elasticsearch \
  --network elasticsearch \
  --restart unless-stopped \
  -p 127.0.0.1:9200:9200 \
  -p 127.0.0.1:9300:9300 \
  -e "discovery.type=single-node" \
  -e "ES_JAVA_OPTS=-Xms512m -Xmx1024m" \
  harbor.yusiwen.cn/library/elasticsearch/elasticsearch-oss-ik:7.9.2
