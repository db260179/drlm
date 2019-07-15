#!/bin/bash

DOCKER_DIR=packaging/docker

source ${DOCKER_DIR}/env.conf

IS_MODULE=`lsmod | grep -o nfsd`
if [[ -z "${IS_MODULE}" ]]; then
	echo "${0}: Missing module nfsd: probing now..."
	sudo modprobe nfsd
fi

if [[ ${USE_PORT_MAPPING} != 0 ]]; then
    DOCKER_NETWORK="-p ${PORT_111_TCP}:111/tcp \
                    -p ${PORT_111_UDP}:111/udp \
                    -p ${PORT_2049_TCP}:2049/tcp \
                    -p ${PORT_2049_UDP}:2049/udp \
                    -p ${PORT_67_TCP}:67/tcp \
                    -p ${PORT_67_UDP}:67/udp \
                    -p ${PORT_69_UDP}:69/udp"
    echo "${0}: Using Docker port mapping."
else
    DOCKER_NETWORK="--network=host"
    echo "${0}: Using Docker Host network mode."
fi

# --name=nfs
docker run --name=drlm-server --rm -t -d --privileged \
${DOCKER_NETWORK} \
-v ${TFTP_DIR}:/var/lib/drlm/store \
-v ${ARCHIVE_DIR}:/var/lib/drlm/arch \
-v ${DRLM_ROOT_DIR}:/var/lib/drlm \
-v ${NFS_DIR}:/nfs \
-v ${DOCKER_DIR}/etc/drlm:/etc/drlm \
-v ${DOCKER_DIR}/etc/exports:/etc/exports \
-v ${DOCKER_DIR}/etc/default/nfs-kernel-server:/etc/default/nfs-kernel-server \
-v ${DOCKER_DIR}/etc/default/isc-dhcp-server:/etc/default/isc-dhcp-server \
-v ${DOCKER_DIR}/etc/dhcp/dhcpd-conf:/etc/dhcp/dhcpd.conf \
-v ${DOCKER_DIR}/etc/network/interfaces:/etc/network/interfaces \
${DOCKER_IMAGE}:${DOCKER_TAG}
