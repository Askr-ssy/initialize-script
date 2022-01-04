#!/bin/bash
source ../utils/utils.sh

isRoot
check_docker


remote_server="example.com"
password="password1"

external_port=11080
remote_port=443
local_port=1080
local_addr="0.0.0.0"

read -p "password: " password
read -p "remote addr: " remote_server

while true; do
    read -p "default local port ? [y/n]: " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) read -p "input local port (default 11080): " external_port; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "default remote port ? [y/n]: " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) read -p "input remote_port (default 443): " remote_port; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "default local addr ? [y/n]: " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) read -p "input local addr (default 127.0.0.1): " local_port; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo ""
echo "check your config"
echo "remote server: " $remote_server
echo "remote port: " $remote_port
echo "password: " $password

echo "container external port: " $external_port
echo "container internal port: " $local_port
echo "local addr: " $local_addr
echo ""

mkdir -p ../.cache
python3 -c "
import json
with open('../Config/trojan-client-example.json', 'r', encoding='utf-8') as file:
    config = json.load(file)

config['local_addr'] = '"$local_addr"'
config['local_port'] = '"$local_port"'
config['remote_addr'] = '"$remote_server"'
config['remote_port'] = '"$remote_port"'
config['password'] = ['$password']
with open('../.cache/trojan-client.json', 'w', encoding='utf-8') as file:
    json.dump(config, file)
"

docker build --network host -f ../Docker/debian11-trojan-client.dockerfile -t trojan-client:1.0 ../.cache/
docker run --detach --publish $external_port:$local_port --restart always --name trojan-askr trojan-client:1.0
rm -rf ../.cache
