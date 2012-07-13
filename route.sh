#! /bin/bash

WLAN0_GW=172.16.134.254
ETH0_GW=172.16.35.254

route add default gw $WLAN0_GW dev wlan0
route del default gw $ETH0_GW dev eth0

route add -net 172.16.11.0 netmask 255.255.255.0 gw $ETH0_GW dev eth0
route add -net 172.16.38.234 netmask 255.255.255.255 gw $ETH0_GW dev eth0
route add -net 172.24.61.0 netmask 255.255.255.0 gw $ETH0_GW dev eth0

route
