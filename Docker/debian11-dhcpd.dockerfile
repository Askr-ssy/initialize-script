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

ARG dhcp_driver
WORKDIR /root
COPY ./dhcpd.conf ./dhcpd.conf
RUN echo ${dhcp_driver}
RUN apt install -y isc-dhcp-server && \
    cat /root/dhcpd.conf >> /etc/dhcp/dhcpd.conf && \
    touch /var/lib/dhcp/dhcpd.leases && \
    sed -i "s/INTERFACESv4=\"\"/INTERFACESv4=\"${dhcp_driver}\"/" /etc/default/isc-dhcp-server
CMD ["/usr/sbin/dhcpd", "-4", "-f", "-cf", "/etc/dhcp/dhcpd.conf", "${dhcp_driver}"]