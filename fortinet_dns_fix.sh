#!/bin/bash

interface_name=fctvpn
interface_name=ppp0

export VPN_INTERFACE=$(resolvectl | grep $interface_name | sed 's/[()]//g' | cut -d' ' -f3)
sudo resolvectl domain $VPN_INTERFACE ~.
sudo resolvectl dns $VPN_INTERFACE 192.168.164.3
