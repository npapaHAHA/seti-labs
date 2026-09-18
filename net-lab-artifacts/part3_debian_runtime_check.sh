#!/usr/bin/env bash
set -u

IFACE=enp0s3

echo "--- reset bond if present ---"
ip link set bond007 down 2>/dev/null || true
ip link set enp0s3 nomaster 2>/dev/null || true
ip link set enp0s8 nomaster 2>/dev/null || true
ip link delete bond007 type bond 2>/dev/null || true

echo "--- apply part 3 runtime addressing ---"
ip addr flush dev "$IFACE"
ip link set "$IFACE" up
ip addr add 10.100.0.4/24 dev "$IFACE"
ip addr add 10.100.0.5/24 dev "$IFACE"
ip route replace default via 10.100.0.3 dev "$IFACE"

echo "--- netplan file ---"
cat /etc/netplan/99-lab.yaml

echo "--- addr/route ---"
ip -br addr show "$IFACE"
ip route

echo "--- ping CentOS real and bridge interfaces ---"
ping -c 3 -W 1 10.100.0.2 || true
ping -c 3 -W 1 10.100.0.3 || true

echo "--- local addresses ---"
ping -c 2 -W 1 10.100.0.4 || true
ping -c 2 -W 1 10.100.0.5 || true

echo "--- arp/neigh cache ---"
ip neigh show dev "$IFACE"
