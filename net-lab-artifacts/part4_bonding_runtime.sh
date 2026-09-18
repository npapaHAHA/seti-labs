#!/usr/bin/env bash
set -u

LOG=/root/part4_bonding.log
exec > >(tee "$LOG") 2>&1

echo "=== part 4 bonding runtime ==="
date

mapfile -t IFS_LIST < <(ls /sys/class/net | grep -v '^lo$' | sort)
echo "Detected interfaces: ${IFS_LIST[*]}"

IF1="${IFS_LIST[0]:-}"
IF2="${IFS_LIST[1]:-}"
if [ -z "$IF1" ] || [ -z "$IF2" ]; then
  echo "ERROR: need two non-loopback interfaces"
  exit 1
fi

echo "Using slaves: $IF1 $IF2"

modprobe bonding
lsmod | grep bonding || true

ip link set bond007 down 2>/dev/null || true
ip link delete bond007 2>/dev/null || true

dhclient -r "$IF1" 2>/dev/null || true
dhclient -r "$IF2" 2>/dev/null || true
dhclient -r bond007 2>/dev/null || true

ip addr flush dev "$IF1" 2>/dev/null || true
ip addr flush dev "$IF2" 2>/dev/null || true
ip link set "$IF1" down
ip link set "$IF2" down

ip link add bond007 type bond mode balance-rr miimon 100
ip link set "$IF1" master bond007
ip link set "$IF2" master bond007
ip link set "$IF1" up
ip link set "$IF2" up
ip link set bond007 up

echo "--- dhclient bond007 ---"
timeout 25 dhclient -1 -v bond007 || true

echo "--- ip -br addr ---"
ip -br addr

echo "--- ip route ---"
ip route

echo "--- /proc/net/bonding/bond007 ---"
cat /proc/net/bonding/bond007

cat >/root/iface_stats.sh <<'EOF'
#!/usr/bin/env bash
IFACE="${1:-bond007}"
echo "time: $(date '+%F %T')"
awk -v iface="$IFACE" '
  $1 ~ iface ":" {
    gsub(":", "", $1);
    print "interface=" $1, "Receive-packets=" $3, "Transmit-packets=" $11
  }
' /proc/net/dev
EOF
chmod +x /root/iface_stats.sh

echo "--- /root/iface_stats.sh ---"
cat /root/iface_stats.sh

echo "--- /proc/net/dev initial ---"
cat /proc/net/dev

echo "--- ping and stats ---"
ping -I bond007 -c 8 8.8.8.8 >/root/bond_ping.log 2>&1 &
PING_PID=$!
for i in 1 2 3; do
  /root/iface_stats.sh bond007
  sleep 2
done
wait "$PING_PID" || true

echo "--- ping output ---"
cat /root/bond_ping.log

echo "--- final /proc/net/dev ---"
cat /proc/net/dev

echo "=== part 4 done ==="
