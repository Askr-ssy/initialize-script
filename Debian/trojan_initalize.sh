#/bin/bash

# ./acme-ssl-nginx.sh

apt update
apt install trojan -y

cp ~/.acme.sh/\*.askr.cc/fullchain.cer /etc/trojan/fullchain.cer
cp ~/.acme.sh/\*.askr.cc/\*.askr.cc.key /etc/trojan/askr.cc.key
chmod 755 /etc/trojan/fullchain.cer
chmod 755 /etc/trojan/askr.cc.key
python3 -c "
import json
import secrets
with open('/etc/trojan/config.json','r') as file:
    config = json.load(file)
    config['local_port'] = 44342
    password = secrets.token_urlsafe()
    config['password'] = [password]
    config['ssl']['cert'] = '/etc/trojan/fullchain.cer'
    config['ssl']['key'] = '/etc/trojan/askr.cc.key'
with open('/etc/trojan/config.json','w') as file:
    json.dump(file,config)
"