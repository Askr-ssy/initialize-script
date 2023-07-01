#!/bin/bash
# 参考 https://wiki.debian.org/NetworkConfiguration
# need debian server

# set environment
net_devices=$(ls /sys/class/net | grep en | sort)
net_interface=(${net_devices// / })
wan_interface=${net_interface[0]}
lan_interfate=${net_interface[@]:1}
dns_server="192.168.42.1"
PATH=$PATH:/usr/sbin

echo "net devices is $net_devices"
echo "wan_interface is $wan_devices"
echo "lan_interfate is $lan_interfate"

# install program
apt install -y pppoeconf privoxy nmap vim python3 python3-pip

# set iptables share network
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.route_localnet = 1" >> /etc/sysctl.conf

iptables -t nat -A POSTROUTING -s 192.168.42.0/24 -o ppp0 -j MASQUERADE
iptables -t nat -A PREROUTING ! -s 192.168.42.0/24 -p tcp --dport 22 -j DNAT --to 192.0.2.1:22
iptables -t nat -A PREROUTING ! -s 192.168.42.0/24 -p tcp --dport 16452 -j REDIRECT --to-port 22
iptables -t filter -A INPUT ! -s 192.168.42.0/24 -p tcp --dport 1080 -j REJECT

echo "post-down iptables-save > /etc/network/iptables.up.rules" >> /etc/network/interfaces
echo "pre-up iptables-restore < /etc/network/iptables.up.rules" >> /etc/network/interfaces

# set pppoe config(pass)
# ## read pppoe config
# pppoe-account=""
# pppoe-password=""
# read -p "Enter your pppoe-account:" pppoe-account
# read -p "Enter your pppoe-password:" pppoe-password
pppoeconf


# set dhcp server
sed -i "s/INTERFACESv4=\"\"/INTERFACESv4=\"${lan_interfate}\"/" /etc/default/isc-dhcp-server
echo "\
subnet 192.168.42.0 netmask 255.255.255.0 {
  range 192.168.42.10 192.168.42.254;
  default-lease-time 600;
  max-lease-time 7200;
  ping-check true;
  ping-timeout 2;

  option routers 192.168.42.1;
  option broadcast-address 192.168.42.255;
  option subnet-mask 255.255.255.0;

  option domain-name \"askr.cn\";
  option domain-search \"askr.cn\";
  option domain-name-servers ${dns_server};
}
authoritative;
" >> /etc/dhcp/dhcpd.conf

# set lan address
# TODO 配置所有的接口（以dhcp的形式）
echo "\

auto ${lan_interfate[0]}
allow-hotplug ${lan_interfate[0]}
iface ${lan_interfate[0]} inet static
  address 192.168.42.1/24
  broadcast 192.168.42.255
  network 192.168.42.0
  dns-nameservers 192.168.42.1
  dns-search askr.cn
" >> /etc/network/interfaces

# set sshd_config
echo "\
LogLevel VERBOSE
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
" >> /etc/sshd_config


# set aliyun ddns
pip3 install aliyun-python-sdk-alidns==2.6.29 -i https://mirrors.aliyun.com/pypi/simple
pip3 install aliyun-python-sdk-core==2.13.35 -i https://mirrors.aliyun.com/pypi/simple
mkdir -p /var/spool/cron/crontabs/script
cp ./aliyun-ddns.py /var/spool/cron/crontabs/script/
echo "*/30 * * * * root python3 /var/spool/cron/crontabs/script/aliyun-ddns.py" >> /etc/crontab

## 配置iptables 防火墙

## TODO 配置代理服务器 trojan

## 配置透明代理(iptables)

## 配置反向代理服务器(nginx)

# init 6

# 手动配置pppoe
# TODO 根据 pppoe 配置的端口,配置 wan 和 lan
# TODO 配置frp
# TODO 配置nginx

# TODO 尝试配置局域网大包
# TODO 配置ipv6 环境

# # 端口映射
# iptables -t nat -A PREROUTING -i eth0 -d 172.18.44.44 -p tcp --dport 2321 -j DNAT --to 100.100.100.101:23
# iptables -t nat -A POSTROUTING -o eth1 -d 100.100.100.101 -p tcp --dport 23 -j SNAT --to 100.100.100.44


# ip rule add fwmark 1 lookup 42
# ip route add local 0.0.0.0/0 dev lo table 42

# iptables -t nat -A POSTROUTING -s 172.19.16.0/20 -o eth0 -j MASQUERADE

# # 创建一个叫 trojan 的链，查看和删除的时候方便
# iptables -t nat -N trojan
# # 所有输出的数据都使用此链
# iptables -t nat -A OUTPUT -p tcp -j trojan

# # 代理自己不要再被重定向，按自己的需求调整/添加。一定不要弄错，否则会造成死循环的
# iptables -t nat -I trojan -m owner --uid-owner trojan -j RETURN
# # iptables -t nat -I trojan -m owner --uid-owner goagent -j RETURN
# # iptables -t nat -I trojan -m owner --uid-owner dnscrypt -j RETURN
# iptables -t nat -A trojan -d os1-8.sstr-api.xyz -j RETURN
# iptables -t nat -A trojan -d 45.142.165.148 -j RETURN



# # 局域网不要代理
# iptables -t nat -A trojan -d 0.0.0.0/8 -j RETURN
# iptables -t nat -A trojan -d 10.0.0.0/8 -j RETURN
# iptables -t nat -A trojan -d 169.254.0.0/16 -j RETURN
# iptables -t nat -A trojan -d 172.16.0.0/12 -j RETURN
# iptables -t nat -A trojan -d 172.19.16.0/20 -j RETURN
# iptables -t nat -A trojan -d 192.168.0.0/16 -j RETURN
# iptables -t nat -A trojan -d 192.168.1.0/24 -j RETURN
# iptables -t nat -A trojan -d 224.0.0.0/4 -j RETURN
# iptables -t nat -A trojan -d 240.0.0.0/4 -j RETURN


# # HTTP 和 HTTPS 转到 trojan
# iptables -t nat -A trojan -p tcp -j REDIRECT --to-ports 1080

# # # 如果使用国外代理的话，走 UDP 的 DNS 请求转到 trojan，trojan 会让其使用 TCP 重试
# # iptables -t nat -A trojan -p udp --dport 53 -j REDIRECT --to-ports $DNS_PORT
# # # 如果走 TCP 的 DNS 请求也需要代理的话，使用下边这句。一般不需要
# # iptables -t nat -A trojan -p tcp --dport 53 -j REDIRECT --to-ports $HTTPS_PORT


# os1-8.sstr-api.xyz
# iptables -t nat -A PREROUTING -p tcp -j trojan

# iptables -t mangle -A OUTPUT -j MARK --set-mark 1
# iptables -t mangle -A PREROUTING -j TPROXY --on-port 1080 --on-ip 127.0.0.1