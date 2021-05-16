#/bin/bash

# ./acme-ssl-nginx.sh

apt update
apt install git trojan nginx -y

mkdir -p /etc/trojan
echo 'H4sIAGAAoWACA+0Ya2/bNjCf/Su4tFvarpJsx0kKG4ZRFH1hzVo0+1BgHQxaOsmsKVIgKT86Zb99R0qyLTtNtmHNMDREQsn35JF3xzuJhImlH0oRH3y10cZxdnbmnjh2n8fdTvug02uftLvtNj4PHHn3mLQPbmHk2lBFyME3Ou6RlyBAUQMRmayIsO5gvYElPpOte2RqTKb7QbBYLPyIJcxQLkOgAl0mDfA/zQUzq8BIyXXguEeRTCkT2m/7GtQclF8ChrnueB2f6pnyw/CHPaqMmunw++6LOVU4oz6cv0gcyTBPQZj3UhrLlOUTzkJ86bZ7T/bJFURMQWgu8kmFG8aUa9iidIaW8xdwsVQhvLqGYKrNdagblYegzC+rDIYhOqVM9/Ba82dIwmIW4nlZs8FYm9224xPxmz1z0vwMbhLzE6xukjSD1Y6gbJrZ/z07lMwNE+g6IoLl0M2oNOVXkCArn9Bw9grRQ6NyuIbm3VpVwuWE8o0h75SMGYdhKiNQoomWoc6ecZlHMacKSgGtVo4uQXYHepsXUUMHrYxFe1gSqFyUzu0jftBaSDUDNc4UhoLWoB0RzY1coxRnKTNj4VZHTk9Ojk8GLQynN5JGBBebc9AtJkKeR7CjC0+i1BVUdB4IOuEQBY9cnkY5MEfX1+T3lmVIc27YmIYhZKaSIcXAoarFIJdA52dS6Hopl62W3aRKRDilSoPZNTs3sfeklKRBRM6U5qgVmTBDW7NcT69BR8Dp6ip0GaRjI2cg9BY6jks8lwmym3EscxFdgTcYM3o8pXo6TulyrNlnt06bCvYIJnk4A1PSnPZKdMgZ7qfjnchoVQvonJ7jXluCe+T89flz93rlmeEhsBR8p6YUGUFM8VzGFrRFRrOM26jDowhkaMB42iig6VrPG5ng0Sfulz1SrcdofdNBMEEGCKycpKTyEVBqBqWk2mPa5XJUloksqBJb6tE9y/SvrzN3y0kttb/xzb/GpJnZ9mv0x4O78Z+M8iTonDJuDyNoXNL/Ul14Q/3XPunt1n849zp39d9tnL/LvdU9wJk2IMpofdIe7MF+7fd/69eIKmsLmgJpeE2JVliZNZIP3rFBRRGU5VpQZugq92gIc4W15F4KadakQU1XX4Yl96bWIHXVUN0dZbolQWWjuw/UamxvM03uoyg3BSTYiCgtuKxl0yhiVgblVW5sLHFneYkrp3m1usv/R/zXmfhrRP/N8W/fm/Hf7eIf6fp+8NXz0zce/9cF1y31/+3T3slu/j8+Pju7y/+30v/XR06mQLGJ0i1Md+PynXzwXijM797brOwe6nF48fT8+dv3r1++/vmQUL6gK6x7G3wfLi48bM5M2Xes+ToD2/3AcIJ5efYF1mdS4I1jPNsKbzQfCqkFi+Mrmd5DjBUtKO+dxHtl02Qgk6dq3GIKwovkQiQKma6UU6u+qPaklndY1fOeViE50sDjI/dlpF99HyG2eewTtGrSJ0e50DQGjwnOBBxtFGH/5xN377TW19IfJPjoPxh9twDOvZnA1T2sLqoIxApZ+de9RK65vW7r+1/n+HQ//ju9k7v4v5X4j+mc4XH7OG3cckiCLXhdHjb68HX73exTHfjS+rqSE2m0b5amIXcD/mdiqdZg9GOSQsToViA9IjaQ+qHWDz76Kc0ejopPW68ZjJIiE0mRsLhAmwqM8GIKLCwWMMkKg6llVKTZcZH2aEFpWGAnXqQsYqNiQeeI6RWpnFviFH9YYbg/SDQvYo7gdP7wfmUPLDOmyo9CZ9GeLRtD9Dx5TGLMOHrfCsR9HhXGxPiPS8EnSFMskLk7WivaSlxPnQKXOpXk3lPO5cJ7qxhGNzl8dDj4WwtLPrOsZafdjzUWNsZafrULy5RcMnDfZqhYVcBQptmYwxw4Oa1A7gtJVYPD0gQZp7hA94rnVr4ssYTf/k7ySeO+NABYDepQscw0wErrH3d5qZGpA7KUJhDgrtpfg7u2fz3+BKa7o1gAGgAA' | base64 --decode | tee /etc/nginx/nginxconfig.io-us1-1.askr.cc.tar.gz > /dev/null
rm -rf /etc/nginx/sites-available/*
rm -rf /etc/nginx/sites-enabled/*
tar -xzvf nginxconfig.io-us1-1.askr.cc.tar.gz

sed -i 's/ 80;/ 127.0.0.1:80;/g' /etc/nginx/sites-available/us1-1.askr.cc.conf

cp /etc/nginx/ssl/askr.cc.cert.pem /etc/trojan/askr.cc.cert.pem
cp /etc/nginx/ssl/askr.cc.key.pem /etc/trojan/askr.cc.key.pem
chmod 755 /etc/trojan/askr.cc.cert.pem
chmod 755 /etc/trojan/askr.cc.key.pem
python3 -c "
import json
import secrets
with open('/etc/trojan/config.json','r') as file:
    config = json.load(file)
    config['remote_port'] = 80
    password = secrets.token_urlsafe()
    print('password: ',password)
    config['password'] = [password]
    config['ssl']['cert'] = '/etc/trojan/askr.cc.cert.pem'
    config['ssl']['key'] = '/etc/trojan/askr.cc.key.pem'
with open('/etc/trojan/config.json','w') as file:
    json.dump(file,config)
"