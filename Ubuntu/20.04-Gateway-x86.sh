#!/bin/bash
# 参考 https://wiki.debian.org/NetworkConfiguration

# set environment
net_devices=$(ls /sys/class/net | grep en | sort)
net_interface=(${net_devices// / })
wan_interface=${net_interface[0]}
lan_interfate=${net_interface[1]}
dns_server="192.168.1.1"


# 配置外网(pppoe) # TODO pppoe 配置的端口,配置 wan 和 lan
apt install -y pppoeconf trojan privoxy bind9 bind9-utils isc-dhcp-server

# ## read pppoe config
# read -p "Enter your pppoe-account:" pppoe-account
# read -p "Enter your pppoe-password:" pppoe-password

# ## set pppoe config(pass)
pppoeconf

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


## 配置iptables 上网
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o $wan_interface -j MASQUERADE
echo "iptables-save > /etc/network/iptables.up.rules" >> /etc/network/interfaces
echo "iptables-restore < /etc/network/iptables.up.rules" >> /etc/network/interfaces

## 配置iptables 防火墙

## TODO 配置代理服务器 trojan

## 配置PAC以及代理服务器(privoxy)

## 配置 bind
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

## 配置内网穿透服务器(frp 搭配vps)

## 配置反向代理服务器(nginx)

# 配置内网地址
rm /etc/netplan/*
echo "\
network:
    version: 2
    renderer: NetworkManager
    ethernets:
        $lan_interfate:
            addresses: [192.168.1.1/24]
            dhcp4: no
            gateway4: 192.168.1.1
            nameservers:
                addresses: [$dns_server,8.8.8.8]
            match:
                macaddress: a0:36:9f:8c:14:4f       
            wakeonlan: true
" > /etc/netplan/01-network-manager-all.yaml

init 6

# TODO 删除 pppoe 传输的dns 服务器，手动配置pppoe
# TODO 配置privoxy
# TODO 配置frp
# TODO 配置nginx
# TODO 尝试配置局域网大包