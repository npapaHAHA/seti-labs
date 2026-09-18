#!/usr/bin/env bash
set -u

IFACE="${1:-$(ip -o link show | awk -F': ' '$2 != "lo" { print $2; exit }')}"
STATIC_IP="10.100.0.2/24"
STATIC_GATE="10.100.0.1"
STATIC_DNS="8.8.8.8"

need_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Run as root."
    exit 1
  fi
}

link_info() {
  echo "Interface: $IFACE"
  echo "Model:"
  basename "$(readlink -f "/sys/class/net/$IFACE/device/driver" 2>/dev/null)" 2>/dev/null || echo "unknown"
  echo "MAC:"
  cat "/sys/class/net/$IFACE/address" 2>/dev/null || echo "unknown"
  echo "Carrier/link:"
  cat "/sys/class/net/$IFACE/carrier" 2>/dev/null || echo "unknown"
  echo "Speed:"
  cat "/sys/class/net/$IFACE/speed" 2>/dev/null || echo "unknown"
  echo "Duplex:"
  cat "/sys/class/net/$IFACE/duplex" 2>/dev/null || echo "unknown"
  if command -v ethtool >/dev/null 2>&1; then
    echo "ethtool:"
    ethtool "$IFACE" 2>/dev/null | egrep 'Speed|Duplex|Link detected'
  fi
}

ipv4_info() {
  echo "IPv4 addresses:"
  ip -4 addr show dev "$IFACE"
  echo "Routes:"
  ip route
  echo "DNS:"
  cat /etc/resolv.conf
}

set_static() {
  need_root
  ip link set "$IFACE" up
  ip -4 addr flush dev "$IFACE"
  ip addr add "$STATIC_IP" dev "$IFACE"
  ip route replace default via "$STATIC_GATE" dev "$IFACE"
  if command -v resolvectl >/dev/null 2>&1; then
    resolvectl dns "$IFACE" "$STATIC_DNS" || true
  else
    echo "No resolvectl; DNS file was not changed by this script."
  fi
  echo "Static runtime config applied."
  ipv4_info
}

set_dhcp() {
  need_root
  ip link set "$IFACE" up
  ip -4 addr flush dev "$IFACE"
  if command -v dhclient >/dev/null 2>&1; then
    dhclient -r "$IFACE" 2>/dev/null || true
    dhclient "$IFACE"
  else
    echo "dhclient is not installed."
  fi
  ipv4_info
}

while true; do
  echo
  echo "1) Link info"
  echo "2) Current IPv4 config"
  echo "3) Set static IPv4 scenario"
  echo "4) Set DHCP scenario"
  echo "5) Exit"
  printf "Choose: "
  read -r choice
  case "$choice" in
    1) link_info ;;
    2) ipv4_info ;;
    3) set_static ;;
    4) set_dhcp ;;
    5) exit 0 ;;
    *) echo "Unknown option" ;;
  esac
done
