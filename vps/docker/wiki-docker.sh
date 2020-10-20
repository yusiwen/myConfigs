docker run -d -p 127.0.0.1:3080:3000 \
    --name wiki \
    --restart unless-stopped \
    -v /var/lib/wiki:/data \
    -e "DB_TYPE=sqlite" \
    -e "DB_FILEPATH=/data/wiki.sqlite" \
    requarks/wiki:latest
