#!/bin/bash
# 参考 https://wiki.debian.org/NetworkConfiguration

# set environment
net_devices=$(ls /sys/class/net | grep en | sort)
net_interface=(${net_devices// / })
wan_interface=${net_interface[0]}
lan_interfate=${net_interface[1]}
dns_server="192.168.1.1"
pppoe-account=""
pppoe-password=""

# ## read pppoe config
# read -p "Enter your pppoe-account:" pppoe-account
# read -p "Enter your pppoe-password:" pppoe-password

# set ppoe conf
apt install -y pppoeconf trojan privoxy bind9 bind9-utils isc-dhcp-server

# set dns server
rm /etc/bind/named.conf.options
echo "\
options {
        directory \"/var/cache/bind\";
        listen-on port 53 { 192.168.1.1; 127.0.0.1; };
        listen-on-v6 port 53 { ::1; };  # TODO 改为 本地端口
        allow-query { 192.168.1.0/24; 127.0.0.1; };
        recursion yes;
        allow-recursion { 192.168.1.0/24; 127.0.0.1; };

        forward first;
        forwarders {
            8.8.8.8;
            114.114.114.114;
        };
        dnssec-enable no;
        dnssec-validation no;
        dnssec-lookaside no;    
};
" > /etc/bind/named.conf.options

echo "\
zone \"askr.cn\" {
    type master;
    file \"/etc/bind/db.askr.cn\";
};
" >> /etc/bind/named.conf.default-zones

echo "\
;
; BIND data file for local loopback interface
;
\$TTL    60
\$ORIGIN askr.cn.
@       IN      SOA     ns.askr.cn. root.askr.cn. (
                              3         ; Serial
                             60         ; Refresh
                             1H         ; Retry
                             3D         ; Expire
                             1D )       ; Negative Cache TTL
;
@       IN      NS      ns
ns      IN      A       192.168.1.1
" > /etc/bind/db.askr.cn


# set dhcp server
sed -i "s/INTERFACESv4=\"\"/INTERFACESv4=\"${lan_interfate}\"/" /etc/default/isc-dhcp-server
echo "\
subnet 192.168.1.0 netmask 255.255.255.0 {
  range 192.168.1.2 192.168.1.230;
  default-lease-time 600;
  max-lease-time 7200;
  ping-check true;
  ping-timeout 2;

  option routers 192.168.1.1;
  option broadcast-address 192.168.1.255;
  option subnet-mask 255.255.255.0;

  option domain-name \"askr.cn\";
  option domain-search \"askr.cn\";
  option domain-name-servers ${dns_server};
}
authoritative;
" >> /etc/dhcp/dhcpd.conf

# set lan address
sed -i "s/auto ${lan_interfate}//" /etc/work/interfaces
sed -i "s/allow-hotplug ${lan_interfate}//" /etc/work/interfaces
sed -i "s/iface ${lan_interfate} inet dhcp//" /etc/work/interfaces
sed -i "s/iface ${lan_interfate} inet manual//" /etc/work/interfaces
echo "\
auto enp0s31f6
iface enp0s31f6 inet static
  address 192.168.0.3/24
  broadcast 192.168.0.255
  network 192.168.0.0
  gateway 192.168.0.1
" >> /etc/work/interfaces

## 配置iptables 防火墙

## TODO 配置代理服务器 trojan

## 配置透明代理(iptables)

## 配置内网穿透服务器(frp 搭配vps)

## 配置反向代理服务器(nginx)

# set pppoe config(pass)
pppoeconf

# set iptables share network
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o ppp0 -j MASQUERADE
echo "post-down iptables-save > /etc/network/iptables.up.rules" >> /etc/network/interfaces
echo "pre-up iptables-restore < /etc/network/iptables.up.rules" >> /etc/network/interfaces

init 6

# 手动配置pppoe
# TODO 根据 pppoe 配置的端口,配置 wan 和 lan
# TODO 配置frp
# TODO 配置nginx

# TODO 尝试配置局域网大包
# TODO 配置ipv6 环境