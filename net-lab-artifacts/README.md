# Network lab artifacts

Итоговая папка для лабораторной:

`C:\Users\egorn\Documents\net-lab-artifacts`

Главный отчет:

- `network_lab_report.tex`

Использованные ВМ:

- `Centos9`: CentOS Stream 9, адаптер 1 переведен в Internal Network `seti-lab`.
- `Debian 12`: Debian 12, адаптер 1 переведен в Internal Network `seti-lab`, адаптер 2 оставлен как NAT Network `lab-nat` после опыта с bonding.

Что выполнено:

- Часть 1: создан и проверен скрипт `part1_net_menu.sh`.
- Часть 2: на CentOS через `nmcli` создан профиль `lab-static` с `10.100.0.2/24`, создан `br0` с `10.100.0.3/24`, пинги успешны.
- Часть 3: на Debian подготовлен `netplan` YAML для `10.100.0.4/24` и `10.100.0.5/24`, выполнена runtime-проверка связи с CentOS, ARP/neighbor cache проверен с обеих сторон.
- Часть 4: на Debian создан `bond007` в режиме round-robin, получен DHCP-адрес `10.10.10.4/24`, сняты `/proc/net/bonding/bond007`, `/proc/net/dev` и статистика RX/TX во время ping.

Скриншоты для отчета:

- `debian12-part1-output.png`
- `centos9-part2-output.png`
- `debian12-part3-final.png`
- `centos9-part3-peer.png`
- `debian12-part4-output.png`
- `debian12-part4-stats.png`

Примечания:

- В задании указаны CentOS 7 и Debian 11, но импортированные OVA содержат CentOS Stream 9 и Debian 12.
- На Debian `netplan apply` не смог перезагрузить `systemd-networkd`, поэтому адреса для проверки также назначались runtime-командами `ip`.
- В опыте bonding `ping -I bond007 8.8.8.8` через VirtualBox NAT Network дал 100% packet loss, но счетчики RX/TX на `bond007` увеличивались.
