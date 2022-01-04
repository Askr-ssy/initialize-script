FROM debian:11

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
    touch /etc/apt/sources.list && \
    echo "\
deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free \
deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free \
deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free \
deb http://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib non-free \
" > /etc/apt/sources.list && \
    apt update && \
    apt install -y apt-transport-https ca-certificates && \
    sed -i 's/http:\/\//https:\/\//g' /etc/apt/sources.list && \
    apt update

RUN apt install -y trojan
COPY ./trojan-client.json /etc/trojan/config.json
EXPOSE 1080
CMD [ "trojan", "-c", "/etc/trojan/config.json"]