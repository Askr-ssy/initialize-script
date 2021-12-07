#!/bin/bash
# 参考:
# https://candinya.com/posts/install-wireguard-on-debian-9/
# https://www.cyberciti.biz/faq/ubuntu-20-04-set-up-wireguard-vpn-server/
# https://github.com/angristan/wireguard-install/blob/master/wireguard-install.sh

source ../../utils.sh

isRoot()

apt update
apt install wireguard
mkdir -p /etc/wireguard
cd /etc/wireguard/
wg genkey | tee privatekey | wg pubkey | tee publickey
touch wg0.conf
chmod 600 {privatekey,publickey,wg0.conf}


echo "
[Interface]
Address = 192.168.43.1/24
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o enp1s0f0 -j MASQUERADE;
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o enp1s0f0 -j MASQUERADE;
ListenPort = 51842
PrivateKey = GEN_PRIVATEKEY
" > wg0.conf
