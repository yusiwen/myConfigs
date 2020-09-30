docker run -d -p 3880:8080 \
    --name teedy \
    --restart unless-stopped \
    -v /data/docs:/data \
    -e "DOCS_BASE_URL=https://doc.yusiwen.cn" \
    sismics/docs:v1.8
