#/bin/bash
apt update
apt upgrade -y

apt install nginx

mkdir -p /etc/nginx/nginxconfig.io/

echo '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' | base64 --decode | tee /etc/nginx/nginxconfig.io-askr.cc.tar.gz > /dev/null

tar -xzvf nginxconfig.io-askr.cc.tar.gz

curl  https://get.acme.sh | sh

read -p "input your Ali_Key: " Ali_Key
read -p "input your Ali_Secret: " Ali_Secret

export Ali_Key=$Ali_Key
export Ali_Secret=$Ali_Secret

acme.sh --issue --dns dns_ali -d "*.askr.cc" -d askr.cc

~/.acme.sh/acme.sh --install-cert -d askr.cc \
    --cert-file /etc/letsencrypt/live/askr.cc/chain.pem \
    --key-file /etc/letsencrypt/live/askr.cc/privkey.pem \
    --fullchain-file /etc/letsencrypt/live/askr.cc/fullchain.pem \
    --reloadcmd "systemctl reload nginx.service"