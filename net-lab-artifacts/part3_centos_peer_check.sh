#!/usr/bin/env bash
set -u

echo "--- ping Debian addresses ---"
ping -c 3 -W 1 10.100.0.4 || true
ping -c 3 -W 1 10.100.0.5 || true

echo "--- CentOS arp/neigh cache ---"
ip neigh show
