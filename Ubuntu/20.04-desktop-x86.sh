#!/bin/bash
source ../utils/utils.sh

release_name=$(lsb_release -cs)

smbd_pass=3933030
smbd_user=askr


# --------------------- install application ------------------------ #
sudo apt update
sudo apt -y upgrade
programs="vim neofetch git guake firefox redis chrome mariadb-server trojan tshark unrar nfs-kernel-server nfs-common samba"

for program in $programs
do
    install_program $program
done

install_docker
install_qbittorrent
install_postman
install_telegram
sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin


# add nfs
mkdir -p /data
sudo chown -R nobody:nogroup /data/
sudo echo "/data 192.168.1.0/24(rw,sync,no_subtree_check)" >> /etc/exports
sudo chmod 777 -R /data
sudo nfs enable
sudo exportfs -a
sudo systemctl restart nfs-kernel-server

# add smb
apt install samba
echo "
[sambashare]
    comment = Samba on Ubuntu
    path = /data
    read only = no
    browsable = yes
" >> /etc/samba/smb.conf
(echo "$smbd_pass"; echo "$smbd_pass") | smbpasswd -s -a $smbd_user
service smbd restart

# ufw settings
ufw allow from 192.168.1.0/24
