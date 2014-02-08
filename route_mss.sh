#!/bin/sh

route add default gw 192.168.43.1 wlan0
route del default gw 10.8.50.254 eth0
route add -net 10.8.252.0 gw 10.8.50.254 netmask 255.255.255.0 eth0
