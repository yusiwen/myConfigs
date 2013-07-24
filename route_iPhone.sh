#!/bin/sh

route add default gw 172.20.10.1 wlan0
route del default gw 134.81.2.254 eth0
route add -net 130.31.1.0 gw 134.81.2.254 netmask 255.255.255.0 eth0
route add -net 134.78.11.0 gw 134.81.2.254 netmask 255.255.255.0 eth0
