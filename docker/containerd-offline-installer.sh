#!/usr/bin/env bash

# ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗        ███████╗██╗  ██╗
# ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║        ██╔════╝██║  ██║
# ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║        ███████╗███████║
# ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║        ╚════██║██╔══██║
# ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗██╗███████║██║  ██║
# ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝╚══════╝╚═╝  ╚═╝
#
# Installation script for containerd offline mode
#
# This script presumes that internet connectivity is not available when running.
# So please manually download the binary packages when internet is available and put them 
# in the same directory as this script.
# 
# Binary packages needed to be installed:
# - containerd: https://github.com/containerd/containerd/releases/download/v1.6.16/cri-containerd-1.6.16-linux-amd64.tar.gz
# - cni-plugins: https://github.com/containernetworking/plugins/releases/download/v1.2.0/cni-plugins-linux-amd64-v1.2.0.tgz
# - nerdctl: https://github.com/containerd/nerdctl/releases/download/v1.2.0/nerdctl-1.2.0-linux-amd64.tar.gz
# - libseccomp (for CentOS/7 only): https://rpmfind.net/linux/centos/8-stream/BaseOS/x86_64/os/Packages/libseccomp-2.5.2-1.el8.x86_64.rpm
#
# yusiwen@gmail.com

# Global variables {{{
COLOR='\033[1;34m'  # Highlighted white
COLOR1='\033[1;32m' # Highligted green
COLOR2='\033[1;33m' # Highligted yellow
NC='\033[0m'

OS=$(uname)
OS_ARCH=$(uname -m)
ARCH=
if [ "$OS_ARCH" = 'x86_64' ]; then
  ARCH='amd64'
elif [ "$OS_ARCH" = 'aarch64' ]; then
  ARCH='arm64'
else
  ARCH=
fi
CODENAME=
OS_NAME=
OS_VERSION=
DISTRO=

if [ -n "$WINDIR" ]; then
  OS='Windows_NT'
  tmp_str=$(cmd //C ver)
  tmp_str="${tmp_str//[$'\t\r\n']/}"
  OS_NAME=$(echo $tmp_str | cut -d '[' -f1)
  OS_VERSION=$(echo $tmp_str | cut -d ' ' -f4 | cut -d ']' -f1)
  DISTRO=$(uname)
else
  if [ -e /etc/os-release ]; then
    ID=$(grep "^ID=" /etc/os-release | cut -d'=' -f2)
    ID_LIKE=$(awk -F= '/^ID_LIKE/{print $2}' /etc/os-release | xargs | cut -d ' ' -f1)
    if [ "$ID" = 'ubuntu' ] || [ "$ID_LIKE" = 'ubuntu' ]; then
      DISTRO='Ubuntu'
      CODENAME=$(grep "^UBUNTU_CODENAME" /etc/os-release | cut -d'=' -f2)
    elif [ "ID" = 'Deepin' ]; then
      DISTRO='Deepin'
      CODENAME='buster'
    else
      DISTRO=$(awk -F= '/^NAME/{print $2}' /etc/os-release | xargs | cut -d ' ' -f1)
    fi
    OS_NAME=$(awk -F= '/^NAME/{print $2}' /etc/os-release | xargs | cut -d ' ' -f1)
    OS_VERSION=$(grep "^VERSION_ID" /etc/os-release | cut -d'=' -f2)
  else
    DISTRO=$OS
  fi
fi
echo -e "${COLOR}Operating System: ${COLOR1}$OS${COLOR} found...${NC}"
echo -e "${COLOR}Distribution: ${COLOR1}$DISTRO ($OS_NAME $OS_VERSION)${COLOR} found...${NC}"

SUDO=
if [ "$OS" = 'Linux' ]; then
  if [ $EUID -ne 0 ]; then
    SUDO=sudo
  fi
fi
# }}}

set -e
set -o pipefail

function install() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if ! type containerd >/dev/null 2>&1; then
      $SUDO mkdir -p /etc/containerd
      $SUDO tar xvzf cri-containerd-1.6.16-linux-amd64.tar.gz -C /
      containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
    fi

    # Install CNI plugins
    if [ ! -d /opt/cni/bin ]; then
      $SUDO mkdir -p /etc/cni/net.d
      $SUDO tar -zxvf cni-plugins-linux-amd64-v1.2.0.tgz -C /opt/cni/bin/
      if [ ! -f /etc/cni/net.d/10-containerd-net.conflist ]; then
        cat << EOF | $SUDO tee /etc/cni/net.d/10-containerd-net.conflist
{
  "cniVersion": "1.0.0",
  "name": "containerd-net",
  "plugins": [
    {
      "type": "bridge",
      "bridge": "cni0",
      "isGateway": true,
      "ipMasq": true,
      "promiscMode": true,
      "ipam": {
        "type": "host-local",
        "ranges": [
          [{
            "subnet": "10.88.0.0/16"
          }],
          [{
            "subnet": "2001:4860:4860::/64"
          }]
        ],
        "routes": [
          { "dst": "0.0.0.0/0" },
          { "dst": "::/0" }
        ]
      }
    },
    {
      "type": "portmap",
      "capabilities": {"portMappings": true}
    }
  ]
}
EOF
      fi
    fi

    if [ "$DISTRO" = 'CentOS' ]; then
      local libseccomp_package
      libseccomp_package=$(rpm -qa | grep libseccomp)
      if [ -n "$libseccomp_package" ]; then
        $SUDO rpm -e "$libseccomp_package" --nodeps
      fi
      $SUDO rpm -ivh libseccomp-2.5.2-1.el8.x86_64.rpm
    fi

    # Install nerdctl
    if ! type nerdctl >/dev/null 2>&1; then
      $SUDO tar xvzf nerdctl-1.2.0-linux-amd64.tar.gz -C /usr/local/bin
    fi
  else
    echo -e "${COLOR}Unsupported on this OS.${NC}"
  fi
}
# }}}

install

echo -e "${COLOR}Installation complete${NC}"
echo -e "${COLOR}To start containerd service, execute:${NC}"
echo -e "    sudo systemctl start containerd.service"
echo -e "${COLOR}You need to add '${COLOR1}/usr/local/bin${COLOR}' to '${COLOR1}secure_path${COLOR}' in '${COLOR1}/etc/sudoers${COLOR}'${NC}"
echo -e "${COLOR}You can run '${COLOR1}sudo visudo${COLOR}' to edit that readonly file${NC}"