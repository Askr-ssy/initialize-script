#!/bin/bash
source ../utils/utils.sh

isRoot
check_docker

mkdir -p ../.cache
cp ../Config/bind9/* ../.cache/

docker build --network host -f ../Docker/debian11-bind9.dockerfile -t bind9:1.0 ../.cache/
docker run --detach --publish 53:53/tcp --publish 53:53/udp --restart always --name bind9-askr bind9:1.0

rm -rf ../.cache