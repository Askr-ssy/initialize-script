function install_program {
    if ! [ -x $1 ]
    then 
        apt install -y $1
    fi
}

function crlf_to_lf {
    if ! [ -f $1 ]
    then echo "file is not found" return 1
    else sed -i ':a;N;$!ba;s/\r\n/\n /g' $1
    fi
}

function install_docker {
    sudo apt-get update
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common
    
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -         
    
    # if ! [ -x $(apt-key fingerprint 0EBFCD88) ]   # TODO 验证
    # then
    #     echo $$
    # fi

    sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $release_name \
    stable"

    sudo apt update
    sudo apt-get install docker-ce docker-ce-cli containerd.io

    sudo usermod -aG docker $(whoami)
}

function uninstall_docker {
    sudo apt-get purge docker-ce docker-ce-cli containerd.io
    sudo rm -rf /var/lib/docker
}
function install_qbittorrent {
    sudo add-apt-repository ppa:qbittorrent-team/qbittorrent-stable
    sudo apt-get update && sudo apt-get install qbittorrent
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
    # TODO 移动文件
}
function install_postman {
    wget -c https://dl.pstmn.io/download/latest/linux64 -O ./postman.tar.gz
    tar -zxvf postman.tar.gz
    rm -f postman.tar.gz
    # TODO 移动文件
}