#!/usr/bin/env bash

function help() {
  echo 'node-init.sh -v --help --interface NIC --address ADDRESS --subnet SUBNET(CIDR) --gateway GATEWAY --dns DNSSERVER --hostname HOSTNAME'
  exit 0
}

# NOTE: This requires GNU getopt.
TEMP=$(getopt -o hvi:a:s:g:d: --long help,verbose,interface:,address:,subnet:,gateway:,dns:,hostname: \
              -n 'node-init.sh' -- "$@")

if [ "$?" != 0 ]; then echo "Terminating..." >&2 ; exit 1 ; fi

# Note the quotes around '$TEMP': they are essential!
eval set -- "$TEMP"

VERBOSE=false
INTERFACE='eth0'
ADDRESS=
SUBNET='24'
GATEWAY='192.168.2.1'
DNS='192.168.2.1'
HOSTNAME=
while true; do
  case "$1" in
    -h | --help ) help ;;
    -v | --verbose ) VERBOSE=true; shift ;;
    -i | --interface ) INTERFACE="$2"; shift 2 ;;
    -a | --address ) ADDRESS="$2"; shift 2 ;;
    -s | --subnet ) SUBNET="$2"; shift 2 ;;
    -g | --gateway ) GATEWAY="$2"; shift 2 ;;
    -d | --dns ) DNS="$2"; shift 2 ;;
    --hostname ) HOSTNAME="$2"; shift 2 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [ "$VERBOSE" = 'true' ]; then
  echo "VERBOSE=$VERBOSE"
  echo "INTERFACE=$INTERFACE"
  echo "ADDRESS=$ADDRESS"
  echo "SUBNET=$SUBNET"
  echo "GATEWAY=$GATEWAY"
  echo "DNS=$DNS"
  echo "HOSTNAME=$HOSTNAME"
fi

sudo hostnamectl set-hostname "$HOSTNAME"
sed -e "s/{{ADDRESS}}/$ADDRESS/g" \
    -e "s/{{HOSTNAME}}/$HOSTNAME/g" \
    hosts.template | sudo tee /etc/hosts

sed -e "s/{{INTERFACE}}/$INTERFACE/g" \
    -e "s/{{ADDRESS}}/$ADDRESS/g" \
    -e "s/{{SUBNET}}/$SUBNET/g" \
    -e "s/{{GATEWAY}}/$GATEWAY/g" \
    -e "s/{{DNS}}/$DNS/g" \
    netplan.yaml.template | sudo tee /etc/netplan/00-installer-config.yaml
