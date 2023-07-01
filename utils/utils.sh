function isRoot() {
	if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
	fi
}

function check_docker {
    if ! [ -x "$(command -v docker)" ]
    then
        echo "not found docker"
        exit 1
    fi
}

function install_program {
    if ! [ -x $1 ]
    then
        apt install -y $1
    fi
}

function crlf_to_lf {
    if ! [ -f $1 ]
    then
        echo "file is not found"
        return 1
    else
        sed -i ':a;N;$!ba;s/\r\n/\n /g' $1
    fi
}

function debian_install_docker {
    if [ -x docker]
    then
        return
    fi
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc;
    do
        apt-get remove $pkg;
    done
    apt-get update
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg

    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt update
    apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo usermod -aG docker $(whoami)
}

function uninstall_docker {
    sudo apt-get purge docker-ce docker-ce-cli containerd.io
    sudo apt-get purge docker-buildx-plugin docker-compose-plugin
    sudo apt-get purge docker-ce-rootless-extras
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
}

function install_qbittorrent {
    sudo add-apt-repository ppa:qbittorrent-team/qbittorrent-stable
    sudo apt-get update && sudo apt-get install -y qbittorrent
}

function uninstall_qbittorrent {
    apt-get --purge remove qbittorrent
    sudo add-apt-repository -r ppa:qbittorrent-team/qbittorrent-stable
}

function install_telegram {
    wget -c https://telegram.org/dl/desktop/linux -O ./telegram.tar.xz
    xz -d ./telegram.tar.xz
    tar -xvf  telegram.tar
    rm -f telegram.tar
    mv ./Telegram /opt/Telegram
}

function install_postman {
    wget -c https://dl.pstmn.io/download/latest/linux64 -O ./postman.tar.gz
    tar -zxvf postman.tar.gz
    rm -f postman.tar.gz
    mv ./Postman /opt/Postman
}