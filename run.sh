#!/bin/bash

DOCKER=docker
IMGNAME=x11vnc/docker-desktop:icaclient

${DOCKER} build --rm -t ${IMGNAME} .

uid=$(id -u)
gid=$(id -g)
vsz="1600x900"

docker_user="ubuntu"
docker_home="/home/${docker_user}"

crostini_ip=$(ip a | grep inet | grep -v -e inet6 -e 127\. -e 172\.  | awk '{print $2}' | cut -f1 -d/ | tr -d '\n')

${DOCKER} run --rm --shm-size 2g -p 6080:6080 -p 5900:5900 \
          --env RESOLUT=${vsz}  \
          --env HOST_UID=${uid} \
          --env HOST_GID=${gid} \
          -v ./:${docker_home}/shared                \
          -v ./config:${docker_home}.config          \
          -v ./icaclient:${docker_home}/.ICAClient   \
          --security-opt seccomp=unconfined --cap-add=SYS_PTRACE \
          ${IMGNAME} startvnc.sh | sed -re "s/localhost:/${crostini_ip}:/g"

