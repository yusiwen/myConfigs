#!/bin/bash

# Sync images from google to my harbor registry with arch in name

set -e
set -o pipefail

COLOR='\033[1;37m' # Highlighted white
COLOR1='\033[1;32m' # Highligted green
COLOR2='\033[1;33m' # Highligted yellow
NC='\033[0m'

OS=$(uname)
OS_ARCH=$(uname -m)
echo -e "${COLOR}Operate System: ${COLOR1}$OS-$OS_ARCH${COLOR} found...${NC}"

if [ -z "$1" ]; then
  echo 'sync.sh REPO:VERSION'
  exit 1
fi

if ! echo -n "$1" | grep -q ':'; then
  echo 'sync.sh REPO:VERSION'
  exit 1
fi

SITE_NAME=$(echo -n "$1" | cut -d '/' -f1)
PACKAGE_NAME="$(echo -n ${1#*/} | cut -d ':' -f1)"
VERSION_NAME=$(echo -n "$1" | cut -d ':' -f2)
ARCH_NAME='amd64'
if [ "$OS_ARCH" = 'aarch64' ]; then
  ARCH_NAME='arm64'
fi

TARGET_SITE='harbor.yusiwen.cn'
LIBRARY_NAME=$SITE_NAME
if [ "$SITE_NAME" = 'k8s.gcr.io' ]; then
  LIBRARY_NAME='google_containers'
fi

echo "SITE_NAME=$SITE_NAME"
echo "LIBRARY_NAME=$LIBRARY_NAME"
echo "PACKAGE_NAME=$PACKAGE_NAME"
echo "VERSION_NAME=$VERSION_NAME"
echo "ARCH_NAME=$ARCH_NAME"

NEW_TAG=$TARGET_SITE/$LIBRARY_NAME/$PACKAGE_NAME-$ARCH_NAME:$VERSION_NAME
echo "NEW_TAG=$NEW_TAG"

echo -e "${COLOR}Pull image: ${COLOR1}$1${COLOR} ...${NC}"
docker pull $1

echo -e "${COLOR}Tag image: ${COLOR1}$NEW_TAG${COLOR} ...${NC}"
docker tag  $1 $NEW_TAG

echo -e "${COLOR}Push image: ${COLOR1}$NEW_TAG${COLOR} ...${NC}"
docker push $NEW_TAG
