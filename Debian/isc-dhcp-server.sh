#!/bin/bash
source ../utils/utils.sh

isRoot
check_docker

net_devices=$(ls /sys/class/net | grep en | sort)
net_interface=(${net_devices// / })
wan_interface=${net_interface[0]}
lan_interfate=${net_interface[@]:1}
dns_server=""

echo "net devices is $net_devices"
echo "default wan_interface is $wan_interface"
echo "default lan_interfate is $lan_interfate"

read -p "local dns_server: " dns_server
read -p "lan_interfate: " lan_interfate



mkdir -p ../.cache
cp ../Config/dhcpd.conf-example ../.cache/dhcpd.conf
sed -i s/\$dns_server/$dns_server/ ../.cache/dhcpd.conf

docker build --build-arg dhcp_driver=${lan_interfate} --network host -f ../Docker/debian11-dhcpd.dockerfile -t isc-dhcp-server:1.0 ../.cache/
docker run --net host --restart always --name dhcpd-askr isc-dhcp-server:1.0
rm -rf ../.cache