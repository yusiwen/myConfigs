#!/bin/bash

docker run -d -p 127.0.0.1:3030:8080 \
       -v "/var/lib/coder:/home/coder/.local/share/code-server" \
       -v "/var/lib/coder-project:/home/coder/project" \
       -e "PASSWORD=XXXXXX" \
       codercom/code-server:3.1.0

