#/bin/bash
apt update

apt install nginx curl git vim -y

curl  https://get.acme.sh | sh

# https://ram.console.aliyun.com/users
read -p "input your Ali_Key: " Ali_Key
read -p "input your Ali_Secret: " Ali_Secret

export Ali_Key=$Ali_Key
export Ali_Secret=$Ali_Secret

~/.acme.sh/acme.sh --issue --dns dns_ali -d "*.askr.cc" -d askr.cc

mkdir -p /etc/nginx/ssl

~/.acme.sh/acme.sh --install-cert -d "*.askr.cc" -d askr.cc \
    --key-file       /etc/nginx/ssl/askr.cc.key.pem  \
    --fullchain-file /etc/nginx/ssl/askr.cc.cert.pem \
    --reloadcmd "systemctl reload nginx"

mkdir -p /var/www/askr.cc/public/
cd /var/www/askr.cc/public/
git clone https://github.com/gabrielecirulli/2048.git