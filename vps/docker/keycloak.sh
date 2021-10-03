#!/bin/bash

DBPWD=$(awk -F "=" '/POSTGRES_KEYCLOAK/ {print $2}' /root/.my.pwd.cnf)
ADMINPWD=$(awk -F "=" '/KEYCLOAK_ADMIN_PASSWORD/ {print $2}' /root/.my.pwd.cnf)

docker run -d --name keycloak \
  --restart unless-stopped \
  --network postgres \
  -p 127.0.0.1:8090:8080 \
  -e DB_VENDOR=POSTGRES\
  -e DB_ADDR=postgres \
  -e DB_DATABASE=keycloak \
  -e DB_USER=keycloak \
  -e DB_PASSWORD="$DBPWD" \
  -e KEYCLOAK_USER=admin \
  -e KEYCLOAK_PASSWORD="$ADMINPWD" \
  -e KEYCLOAK_FRONTEND_URL="https://sso.yusiwen.cn/auth" \
  quay.io/keycloak/keycloak:latest
