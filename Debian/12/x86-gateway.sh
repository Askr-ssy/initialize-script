#!/bin/bash
set -e

# set environment
net_devices=$(ls /sys/class/net | grep en | sort)
net_interface=($net_devices)
wan_interface=${net_interface[0]}
lan_interfate=${net_interface[@]:1}
lan_interfate=($lan_interfate)

lan_ip="172.16.0.1/16"
lan_network="172.16.0.0/16"
lan_broadcast="172.16.255.255"
netmask="255.255.0.0"
dhcp_ip_min="172.16.0.2"
dhcp_ip_max="172.16.255.254"
dhcp_subnet="172.16.0.0"
dhcp_route="172.16.0.1"
domain_name="askr.cn"
dns_server=$dhcp_route
PATH=$PATH:/usr/sbin

echo "net devices is $net_devices"
echo "wan_interface is $wan_interface"
echo "lan_interfate is $lan_interfate"

# set apt sources
echo "\
deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
" > /etc/apt/sources.list
apt update
apt install -y apt-transport-https ca-certificates

echo "\
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware

deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware

deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware

# deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware

deb https://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
deb-src https://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
" > /etc/apt/sources.list

# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=973581
echo "Acquire::http::Pipeline-Depth \"0\";" > /etc/apt/apt.conf.d/99nopipelining

# install package
apt update
apt install -y pppoeconf nmap vim python3 python3-pip openssh-server isc-dhcp-server bind9

pppoeconf

# set nftables masquerade shape
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.ipv6.ip_forward = 1" >> /etc/sysctl.conf

# enable nftables
systemctl enable nftables

# set nftables rule
nft flush ruleset
nft add table ip gateway
nft add chain ip gateway prerouting { type nat hook prerouting priority dstnat \; policy accept \; }
nft add chain ip gateway postrouting { type nat hook postrouting priority srcnat \; policy accept \; }
nft add rule ip gateway prerouting ip saddr $lan_network iifname "ppp0" drop
nft add rule ip gateway postrouting ip saddr $lan_network oifname "ppp0" masquerade

nft list ruleset > /etc/nftables.rules
echo "include \"/etc/nftables.rules\"" >> /etc/nftables.conf

# set dhcp server
sed -i "s/INTERFACESv4=\"\"/INTERFACESv4=\"${lan_interfate[0]}\"/" /etc/default/isc-dhcp-server
# sed -i "s/INTERFACESv6=\"\"/INTERFACESv6=\"${lan_interfate[0]}\"/" /etc/default/isc-dhcp-server

echo "\
subnet $dhcp_subnet netmask $netmask {
  range $dhcp_ip_min $dhcp_ip_max;
  default-lease-time 600;
  max-lease-time 7200;
  ping-check true;
  ping-timeout 2;

  option routers $dhcp_route;
  option broadcast-address $lan_broadcast;
  option subnet-mask $netmask;

  option domain-name \"$domain_name\";
  option domain-search \"$domain_name\";
  option domain-name-servers ${dns_server};
}
authoritative;

" >> /etc/dhcp/dhcpd.conf
systemctl enable isc-dhcp-server

# set network interfaces
echo "\

auto ${lan_interfate[0]}
allow-hotplug ${lan_interfate[0]}
iface ${lan_interfate[0]} inet static
  address $lan_ip
  broadcast $lan_broadcast
  network $lan_network
  dns-nameservers $lan_ip
  dns-search $domain_name
" >> /etc/network/interfaces

# set dns server
rm -rf /etc/bind/named.conf.options
echo "\
options {
        directory \"/var/cache/bind\";
        listen-on port 53 { $lan_network; };
        listen-on-v6 port 53 { any; };
        allow-query { $lan_network; };
        recursion yes;
        allow-recursion { $lan_network; };

        forward first;
        forwarders {
            8.8.8.8;
            114.114.114.114;
        };
        dnssec-validation no;
};
" > /etc/bind/named.conf.options

echo "\
zone \"askr.cn\" {
    type master;
    file \"/etc/bind/db.askr.cn\";
};
" >> /etc/bind/named.conf.default-zones

rm -rf /etc/bind/db.askr.cn
echo "\
;
; BIND data file for local loopback interface
;
$TTL    60
$ORIGIN askr.cn.
@       IN      SOA     ns.askr.cn. root.askr.cn. (
                              3         ; Serial
                             60         ; Refresh
                             1H         ; Retry
                             3D         ; Expire
                             1D )       ; Negative Cache TTL
;
@       IN      NS      ns
ns      IN      A       172.16.0.1
gateway IN      A       172.16.0.1
" > /etc/bind/db.askr.cn
systemctl start bind9
systemctl enable bind9


# set ssh secure configuration
su askr
cd ~
ssh -vT -y git@github.com
ssh-keygen -t rsa -b 4096 -f "local.key"
mkdir -p ~/.ssh/
cat local.key.pub >> ~/.ssh/authorized_keys
su root
echo "\
LogLevel VERBOSE
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
PermitEmptyPasswords no
Port 16452
X11Forwarding no
IgnoreRhosts yes
MaxAuthTries 3
Protocol 2
AllowUsers askr lain
" >> /etc/ssh/sshd_config
sshd -t


# set aliyun ddns
su root
cd ~
python3 -m venv aliyundns-venv
/root/aliyundns-venv/bin/python3 -m pip install alibabacloud_alidns20150109==3.0.7 -i https://mirrors.aliyun.com/pypi/simple
mkdir -p /var/spool/cron/crontabs/script
cp ../aliyun-ddns.py /var/spool/cron/crontabs/script/
echo "*/30 * * * * root /root/aliyundns-venv/bin/python3 /var/spool/cron/crontabs/script/aliyun-ddns.py" >> /etc/crontab
