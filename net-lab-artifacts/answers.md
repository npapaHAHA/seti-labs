# Net lab answers

## ip commands

- New IPv4 address: `ip addr add 10.100.0.2/24 dev enp0s3`
- New MAC address: `ip link set dev enp0s3 address 02:11:22:33:44:55`
- New default gateway: `ip route replace default via 10.100.0.1 dev enp0s3`
- Show ARP cache: `ip neigh`
- Flush ARP cache: `ip neigh flush all`
- Enable interface: `ip link set enp0s3 up`
- Disable interface: `ip link set enp0s3 down`

## nmcli static IPv4

```bash
nmcli con add type ethernet ifname enp0s3 con-name lab-static \
  ipv4.method manual ipv4.addresses 10.100.0.2/24 \
  ipv4.gateway 10.100.0.1 ipv4.dns 8.8.8.8
nmcli con up lab-static
```

## netplan static IPv4

Use `part3_debian_netplan_99-lab.yaml`, then:

```bash
netplan generate
netplan apply
```

## Linux bonding modes

- `balance-rr` / mode 0: round-robin, increases throughput, requires switch support for correct operation in many networks.
- `active-backup` / mode 1: one active link and failover, no special switch support.
- `balance-xor` / mode 2: transmit based on hash, often needs switch aggregation support.
- `broadcast` / mode 3: sends all packets on all slaves, high redundancy, special cases only.
- `802.3ad` / mode 4: LACP aggregation, requires switch LACP support.
- `balance-tlb` / mode 5: adaptive transmit load balancing, no special switch support.
- `balance-alb` / mode 6: adaptive load balancing for transmit and receive, no special switch support.

## Duplex modes

- Half duplex: device can either transmit or receive at one moment.
- Full duplex: device can transmit and receive simultaneously.
- Auto negotiation: devices negotiate speed and duplex automatically.

## Multiple IP addresses on one interface

Useful for hosting several services or virtual hosts, migrations, failover addresses, separate subnets on one physical link, and temporary compatibility during renumbering.

## Virtual interfaces

Useful for bridges, VLANs, containers, routing labs, isolation, traffic testing, and creating logical networks without additional physical NICs.
