#!/usr/bin/env bash

export LDAP_ADMIN_PASSWORD=$(awk -F "=" '/LDAP_ADMIN_PASSWORD/ {print $2}' /root/.my.pwd.cnf)
export LDAP_CONFIG_PASSWORD=$(awk -F "=" '/LDAP_CONFIG_PASSWORD/ {print $2}' /root/.my.pwd.cnf)
export LDAP_READONLY_USER_PASSWORD=$(awk -F "=" '/LDAP_READONLY_USER_PASSWORD/ {print $2}' /root/.my.pwd.cnf)

echo "LDAP_ADMIN_PASSWORD=$LDAP_ADMIN_PASSWORD"
echo "LDAP_CONFIG_PASSWORD=$LDAP_CONFIG_PASSWORD"
echo "LDAP_READONLY_USER_PASSWORD=$LDAP_READONLY_USER_PASSWORD"

cd ~/git/myDocker/dbms/openldap
docker-compose -p openldap "$@"