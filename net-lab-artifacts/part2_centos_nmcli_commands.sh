#!/usr/bin/env bash
set -u

IFACE="${1:-enp0s3}"

# VirtualBox: Adapter 1 -> Internal Network -> seti-lab

nmcli con show
nmcli con add type ethernet ifname "$IFACE" con-name lab-static ipv4.method manual ipv4.addresses 10.100.0.2/24 ipv4.gateway 10.100.0.1 ipv4.dns 8.8.8.8 autoconnect yes
nmcli con up lab-static

nmcli con add type bridge ifname br0 con-name br0 ipv4.method manual ipv4.addresses 10.100.0.3/24 autoconnect yes
nmcli con up br0

ip -br addr
ip route
ping -c 3 10.100.0.3
ip link show br0
cat /sys/class/net/br0/address
