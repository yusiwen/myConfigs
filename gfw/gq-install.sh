#!/usr/bin/env bash

# Original script: cbeuw/shadowsocks-gq-release.sh(https://gist.github.com/cbeuw/2c641917e94a6962693f138e287f1e10)
# Edited by yusiwen
# -------------------------

# Forked and modified by cbeuw from https://github.com/teddysun/shadowsocks_install/blob/master/shadowsocks-all.sh

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

[[ $EUID -ne 0 ]] && echo -e "[${red}Error${plain}] This script must be run as root!" && exit 1

shadowsocks_libev_config=/etc/shadowsocks-libev/config.json

# Stream Ciphers
common_ciphers=(
aes-256-gcm
aes-192-gcm
aes-128-gcm
aes-256-ctr
aes-192-ctr
aes-128-ctr
aes-256-cfb
aes-192-cfb
aes-128-cfb
camellia-128-cfb
camellia-192-cfb
camellia-256-cfb
xchacha20-ietf-poly1305
chacha20-ietf-poly1305
chacha20-ietf
chacha20
salsa20
rc4-md5
)

archs=(
amd64
386
arm
arm64
)

check_sys(){
  local checkType=$1
  local value=$2

  local release=''
  local systemPackage=''

  if [[ -f /etc/redhat-release ]]; then
    release="centos"
    systemPackage="yum"
  elif grep -Eqi "debian" /etc/issue; then
    release="debian"
    systemPackage="apt"
  elif grep -Eqi "ubuntu" /etc/issue; then
    release="ubuntu"
    systemPackage="apt"
  elif grep -Eqi "centos|red hat|redhat" /etc/issue; then
    release="centos"
    systemPackage="yum"
  elif grep -Eqi "debian|raspbian" /proc/version; then
    release="debian"
    systemPackage="apt"
  elif grep -Eqi "ubuntu" /proc/version; then
    release="ubuntu"
    systemPackage="apt"
  elif grep -Eqi "centos|red hat|redhat" /proc/version; then
    release="centos"
    systemPackage="yum"
  fi

  if [[ "${checkType}" == "sysRelease" ]]; then
    if [ "${value}" == "${release}" ]; then
      return 0
    else
      return 1
    fi
  elif [[ "${checkType}" == "packageManager" ]]; then
    if [ "${value}" == "${systemPackage}" ]; then
      return 0
    else
      return 1
    fi
  fi
}

install_goquiet(){
  while true
  do
    echo -e "Please choose your system's architecture:"

    for ((i=1;i<=${#archs[@]};i++ )); do
      hint="${archs[$i-1]}"
      echo -e "${green}${i}${plain}) ${hint}"
    done
    read -r "What's your architecture? (Default: ${archs[0]}):" pick
    [ -z "$pick" ] && pick=1
    expr ${pick} + 1 &>/dev/null
    if [ $? -ne 0 ]; then
      echo -e "[${red}Error${plain}] Please enter a number"
      continue
    fi
    if [[ "$pick" -lt 1 || "$pick" -gt ${#archs[@]} ]]; then
      echo -e "[${red}Error${plain}] Please enter a number between 1 and ${#archs[@]}"
      continue
    fi
    gqarch=${archs[$pick-1]}
    echo
    echo "arch = ${gqarch}"
    echo
    break
  done

  url=$(wget -O - -o /dev/null https://api.github.com/repos/cbeuw/GoQuiet/releases/latest | grep "/gq-server-linux-$gqarch-" | grep -P 'https(.*)[^"]' -o)
  echo "$url"
  wget -O gq-server "$url"
  chmod +x gq-server
  sudo mv gq-server /usr/local/bin
}


install_shadowsocks_libev(){
  if check_sys packageManager yum; then
    dnf copr enable librehat/shadowsocks
    yum update
    yum -y install shadowsocks
  elif check_sys packageManager apt; then
    apt -y update
    apt install shadowsocks-libev
  fi

}

install_prepare_goquiet(){
  while true
  do
    echo -e "Do you want install GoQuiet for shadowsocks-libev? [y/n]"
    read -r "(default: y):" goquiet
    [ -z "$goquiet" ] && goquiet=y
    case "${goquiet}" in
      y|Y|n|N)
        echo
        echo "You choose = ${goquiet}"
        echo
        break
        ;;
      *)
        echo -e "[${red}Error${plain}] Please only enter [y/n]"
        ;;
    esac
  done

  if [ "${goquiet}" == "y" ] || [ "${goquiet}" == "Y" ]; then
    echo -e "Please enter a redirection IP for GoQuiet (leave blank to set it to 204.79.197.200:443 of bing.com):"
    read -r "" gqwebaddr
    [ -z "$gqwebaddr" ] && gqwebaddr="204.79.197.200:443"
    echo -e "Please enter a key for GoQuiet (leave blank to use shadowsocks' password):"
    read -r "" gqkey
    [ -z "$gqkey" ] && gqkey="${shadowsockspwd}"
  fi
}

get_ipv6(){
  local ipv6=$(wget -qO- -t1 -T2 ipv6.icanhazip.com)
  [ -z ${ipv6} ] && return 1 || return 0
}

config_shadowsocks(){
  local server_value="\"0.0.0.0\""
  if get_ipv6; then
    server_value="[\"[::0]\",\"0.0.0.0\"]"
  fi

  if [ ! -d "$(dirname ${shadowsocks_libev_config})" ]; then
    mkdir -p "$(dirname ${shadowsocks_libev_config})"
  fi

  if [ "${goquiet}" == "y" ] || [ "${goquiet}" == "Y" ]; then
    cat > ${shadowsocks_libev_config}<<-EOF
{
    "server":${server_value},
    "server_port":${shadowsocksport},
    "password":"${shadowsockspwd}",
    "timeout":300,
    "user":"nobody",
    "method":"${shadowsockscipher}",
    "fast_open":false,
    "nameserver":"8.8.8.8",
    "plugin":"gq-server",
    "plugin_opts":"WebServerAddr=${gqwebaddr};Key=${gqkey}"
}
EOF

     else
       cat > ${shadowsocks_libev_config}<<-EOF
{
    "server":${server_value},
    "server_port":${shadowsocksport},
    "password":"${shadowsockspwd}",
    "timeout":300,
    "user":"nobody",
    "method":"${shadowsockscipher}",
    "fast_open":false,
    "nameserver":"8.8.8.8",
    "mode":"tcp_and_udp"
}
EOF

fi
}


install(){
  echo "Please enter password for shadowsocks-libev:"
  read -r "(Default password: github.com):" shadowsockspwd
  [ -z "${shadowsockspwd}" ] && shadowsockspwd="github.com"
  echo
  echo "password = ${shadowsockspwd}"
  echo

  while true
  do
    dport=443
    echo -e "Please enter a port for shadowsocks-libev [1-65535]"
    read -r "(Default port: ${dport}):" shadowsocksport
    [ -z "${shadowsocksport}" ] && shadowsocksport=${dport}
    expr ${shadowsocksport} + 1 &>/dev/null
    if [ $? -eq 0 ]; then
      if [ ${shadowsocksport} -ge 1 ] && [ ${shadowsocksport} -le 65535 ] && [ ${shadowsocksport:0:1} != 0 ]; then
        echo
        echo "port = ${shadowsocksport}"
        echo
        break
      fi
    fi
    echo -e "[${red}Error${plain}] Please enter a correct number [1-65535]"
  done

  while true
  do
    echo -e "Please select stream cipher for shadowsocks-libev:"

    for ((i=1;i<=${#common_ciphers[@]};i++ )); do
      hint="${common_ciphers[$i-1]}"
      echo -e "${green}${i}${plain}) ${hint}"
    done
    read -r "Which cipher you'd select(Default: ${common_ciphers[0]}):" pick
    [ -z "$pick" ] && pick=1
    expr ${pick} + 1 &>/dev/null
    if [ $? -ne 0 ]; then
      echo -e "[${red}Error${plain}] Please enter a number"
      continue
    fi
    if [[ "$pick" -lt 1 || "$pick" -gt ${#common_ciphers[@]} ]]; then
      echo -e "[${red}Error${plain}] Please enter a number between 1 and ${#common_ciphers[@]}"
      continue
    fi
    shadowsockscipher=${common_ciphers[$pick-1]}
    echo
    echo "cipher = ${shadowsockscipher}"
    echo
    break
  done
  install_shadowsocks_libev
  install_prepare_goquiet
  install_goquiet
  config_shadowsocks
  echo "Enjoy!"
}

uninstall(){
  printf "Are you sure uninstall ${red}shadowsocks-libev${plain}? [y/n]\n"
  read -r "(default: n):" answer
  [ -z ${answer} ] && answer="n"
  if [ "${answer}" == "y" ] || [ "${answer}" == "Y" ]; then
    if check_sys packageManager yum; then
      yum -ye shadowsocks
    elif check_sys packageManager apt; then
      apt remove -y --purge shadowsocks-libev
    fi
    rm -rf /usr/local/bin/gq-server
  else
    echo
    echo -e "[${green}Info${plain}] shadowsocks-libev uninstall cancelled, nothing to do..."
    echo
  fi
}

# Initialization step
action=$1
[ -z "$1" ] && action=install
case "${action}" in
  install|uninstall)
    ${action}
    ;;
  *)
    echo "Arguments error! [${action}]"
    echo "Usage: $(basename "$0") [install|uninstall]"
    ;;
esac
