#!/usr/bin/env bash
set -u

BOND="bond007"
IF1="${1:-enp0s3}"
IF2="${2:-enp0s8}"

modprobe bonding
lsmod | grep bonding

nmcli con add type bond ifname "$BOND" con-name "$BOND" mode balance-rr ipv4.method auto
nmcli con add type ethernet ifname "$IF1" con-name "${BOND}-${IF1}" master "$BOND"
nmcli con add type ethernet ifname "$IF2" con-name "${BOND}-${IF2}" master "$BOND"
nmcli con up "$BOND"
nmcli con up "${BOND}-${IF1}"
nmcli con up "${BOND}-${IF2}"

ip -br addr
cat "/proc/net/bonding/$BOND"
