#!/bin/bash
# 参考 https://wiki.debian.org/NetworkConfiguration

# set environment
net_devices=$(ls /sys/class/net | grep en | sort)
wan_interface=(${net_devices// / }[0])
lan_interfate=(${net_devices// / }[1])
dns_server="8.8.8.8"
dns_server_backup="8.8.8.8"

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

# 配置外网(pppoe)
apt install -y pppoeconf

# ## read pppoe config
# read -p "Enter your pppoe-account:" pppoe-account
# read -p "Enter your pppoe-password:" pppoe-password

# ## set pppoe config(pass)

pppoeconf

# 配置dhcp服务器 /etc/default/dhcp.conf /etc/dhcp/dhcpd.conf
apt install -y isc-dhcp-server

## 配置dns服务器(powerDns)

## 配置iptables 上网
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o $wan_interface -j MASQUERADE
echo "iptables-save > /etc/network/iptables.up.rules" >> 
iptables-restore < /etc/network/iptables.up.rules

## 配置iptables 防火墙

## 配置代理服务器 trojan

## 配置PAC以及代理服务器(privoxy)

## 配置反向代理服务器(nginx)

## 配置内网穿透服务器(frp 搭配vps)
