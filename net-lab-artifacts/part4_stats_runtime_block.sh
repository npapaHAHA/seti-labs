cat >/root/iface_stats.sh <<'EOS'
#!/usr/bin/env bash
IFACE="${1:-bond007}"
echo "time: $(date '+%F %T')"
awk -v iface="$IFACE" '
  $1 ~ iface ":" {
    gsub(":", "", $1);
    print "interface=" $1, "Receive-packets=" $3, "Transmit-packets=" $11
  }
' /proc/net/dev
EOS
chmod +x /root/iface_stats.sh
ip link set enp0s3 up
ip link set enp0s8 up
echo '--- bond007 ---'
cat /proc/net/bonding/bond007
echo '--- stats script ---'
cat /root/iface_stats.sh
echo '--- ping and stats ---'
ping -I bond007 -c 8 8.8.8.8 >/root/bond_ping.log 2>&1 &
for i in 1 2 3; do
  /root/iface_stats.sh bond007
  sleep 2
done
wait
cat /root/bond_ping.log
echo '--- /proc/net/dev ---'
cat /proc/net/dev
