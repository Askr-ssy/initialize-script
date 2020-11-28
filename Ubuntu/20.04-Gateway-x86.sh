#!/bin/bash
# 参考 https://wiki.debian.org/NetworkConfiguration

# set environment
net_devices=$(ls /sys/class/net | grep en | sort)
inside_interface=(${net_devices// / }[0])
dns_server="8.8.8.8"
dns_server_backup="8.8.8.8"

# 配置内网地址
rm /etc/netplan/*
echo "\
network:
    version: 2
    renderer: NetworkManager
    ethernets:
        $inside_interface:
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

# 配置dhcp服务器
apt install -y isc-dhcp-server

## 配置dns服务器

## 配置iptables

## 配置代理服务器

## 配置PAC以及代理服务器
