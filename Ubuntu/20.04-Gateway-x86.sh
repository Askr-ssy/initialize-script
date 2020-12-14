#!/bin/bash
# 参考 https://wiki.debian.org/NetworkConfiguration

# set environment
net_devices=$(ls /sys/class/net | grep en | sort)
net_interface=(${net_devices// / })
wan_interface=${net_interface[0]}
lan_interfate=${net_interface[1]}
dns_server="8.8.8.8"
dns_server_backup="8.8.8.8"


# 配置外网(pppoe) # TODO 根据配置的端口，配置WAN和Lan
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
  option routers 192.168.1.1;
  default-lease-time 600;
  max-lease-time 7200;
}
" >> /etc/dhcp/dhcpd.conf


## 配置iptables 上网
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o $wan_interface -j MASQUERADE
echo "iptables-save > /etc/network/iptables.up.rules" >> /etc/network/interfaces
echo "iptables-restore < /etc/network/iptables.up.rules" >> /etc/network/interfaces

## 配置iptables 防火墙

## TODO 配置代理服务器 trojan

## 配置PAC以及代理服务器(privoxy)


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
                addresses: [$dns_server,$dns_server_backup]
            match:
                macaddress: a0:36:9f:8c:14:4f       
            wakeonlan: true
" > /etc/netplan/01-network-manager-all.yaml

init 6

# TODO 配置DNS(BIND)
# TODO 修改dhcp-dns server
# TODO 删除 pppoe 传输的dns 服务器，手动配置pppoe
# TODO 配置privoxy
# TODO 配置frp
# TODO 配置nginx
# TODO 尝试配置局域网大包