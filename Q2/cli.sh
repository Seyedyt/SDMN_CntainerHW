#!/bin/bash

UBUNTU_ROOTFS_PATH="/ubuntu_rootfs"

create_container() {
    hostname=$1
    memory_limit=$2
    echo "Creating container with hostname: $hostname"

    if [ ! -z "$memory_limit" ]; then
        echo "Setting memory limit: ${memory_limit}MB"
    fi

    # Create the new namespaces and run a shell
    unshare --fork --pid --mount-proc --net --uts --mount /bin/bash -c "
    set -e
    echo 'Setting hostname'
    hostname $hostname

    echo 'Mounting new filesystem'
    mkdir -p /mnt/oldroot
    mount --bind $UBUNTU_ROOTFS_PATH /mnt
    pivot_root /mnt /mnt/oldroot

    echo 'Changing directory to new root'
    cd /

    echo 'Checking if old root directory exists'
    if [ ! -d /oldroot ]; then
        echo '/oldroot directory does not exist, creating manually'
        mkdir /oldroot
    fi

    echo 'Listing new root'
    ls /

    echo 'Listing old root'
    ls /oldroot

    echo 'Unmounting old root'
    umount -l /oldroot || echo 'umount /oldroot failed'

    echo 'Removing old root directory'
    rmdir /oldroot || echo 'rmdir /oldroot failed'

    if [ ! -z '$memory_limit' ]; then
        echo 'Setting memory limit'
        mkdir -p /sys/fs/cgroup/memory/container
        echo $((memory_limit * 1024 * 1024)) > /sys/fs/cgroup/memory/container/memory.limit_in_bytes
        echo $$ > /sys/fs/cgroup/memory/container/cgroup.procs
    fi

    echo 'Entering new namespace'
    exec /bin/bash" &
    pid=$!

    # Wait for the process to start and enter the namespaces
    sleep 1

    if [ -d "/proc/$pid/ns" ]; then
        nsenter --target $pid --uts --mount --net --pid /bin/bash
    else
        echo "Failed to create container: process $pid does not exist"
        exit 1
    fi
}

if [ $# -lt 1 ]; then
    echo "Usage: $0 <hostname> [memory_limit]"
    exit 1
fi

hostname=$1
memory_limit=$2
create_container $hostname $memory_limit

