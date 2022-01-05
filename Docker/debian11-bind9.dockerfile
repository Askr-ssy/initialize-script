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

WORKDIR /root
EXPOSE 53
RUN apt install -y bind9 && \
    rm /etc/bind/named.conf.options
COPY ./named.conf.options-example /etc/bind/named.conf.options
COPY ./db.askr.cn-example /etc/bind/db.askr.cn
COPY ./named.conf.default-zones-example ./named.conf.default-zones
RUN cat named.conf.default-zones >> /etc/bind/named.conf.default-zones
CMD ["/usr/sbin/named", "-f", "-u", "bind"]
