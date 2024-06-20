#!/bin/bash

UBUNTU_ROOTFS_PATH="/ubuntu_rootfs"  

create_container() {
    hostname=$1
    memory_limit=$2
    echo "Creating container with hostname: $hostname"
    if [ ! -z "$memory_limit" ]; then
        echo "Setting memory limit: ${memory_limit}MB"
    fi
    unshare --fork --pid --mount-proc --net --uts --mount /bin/bash &
    sleep 1
    pid=$!
    echo "Setting hostname"
    nsenter --target $pid --uts --hostname $hostname
    echo "Mounting new filesystem"
    mount --bind $UBUNTU_ROOTFS_PATH /mnt
    pivot_root /mnt /mnt/oldroot
    umount /mnt/oldroot
    rmdir /mnt/oldroot
    if [ ! -z "$memory_limit" ]; then
        mkdir -p /sys/fs/cgroup/memory/container
        echo $((memory_limit * 1024 * 1024)) > /sys/fs/cgroup/memory/container/memory.limit_in_bytes
        echo $pid > /sys/fs/cgroup/memory/container/cgroup.procs
    fi
    echo "Entering new namespace"
    nsenter --target $pid --all /bin/bash
}

if [ $# -lt 1 ]; then
    echo "Usage: $0 <hostname> [memory_limit]"
    exit 1
fi

hostname=$1
memory_limit=$2
create_container $hostname $memory_limit

