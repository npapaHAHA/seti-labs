#!/usr/bin/env bash
set -u

IFACE="${1:-bond007}"
echo "time: $(date '+%F %T')"
awk -v iface="$IFACE" '
  $1 ~ iface ":" {
    gsub(":", "", $1);
    print "interface=" $1, "Receive-packets=" $3, "Transmit-packets=" $11
  }
' /proc/net/dev
