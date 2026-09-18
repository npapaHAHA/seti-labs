#!/usr/bin/env bash
set -u

echo "--- interfaces before ---"
ip -br link

IFACE=$(ip -o link show | awk -F': ' '$2 != "lo" { print $2; exit }' | cut -d@ -f1)
echo "IFACE=$IFACE"

echo "--- nmcli device status ---"
nmcli dev status

nmcli con delete lab-static >/dev/null 2>&1 || true
nmcli con delete br0 >/dev/null 2>&1 || true

echo "--- static profile 10.100.0.2/24 ---"
nmcli con add type ethernet ifname "$IFACE" con-name lab-static \
  ipv4.method manual \
  ipv4.addresses 10.100.0.2/24 \
  ipv4.gateway 10.100.0.1 \
  ipv4.dns 8.8.8.8 \
  autoconnect yes
nmcli con up lab-static || true

echo "--- bridge interface br0 10.100.0.3/24 ---"
nmcli con add type bridge ifname br0 con-name br0 \
  ipv4.method manual \
  ipv4.addresses 10.100.0.3/24 \
  autoconnect yes
nmcli con up br0 || true

echo "--- addr/route ---"
ip -br addr
ip route

echo "--- ping between real and virtual interfaces ---"
ping -c 3 -W 1 10.100.0.3 || true
ping -c 3 -W 1 10.100.0.2 || true

echo "--- br0 mac ---"
cat /sys/class/net/br0/address

echo "--- active nmcli profiles ---"
nmcli -f NAME,TYPE,DEVICE con show --active
