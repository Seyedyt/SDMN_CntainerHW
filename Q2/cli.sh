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
    unshare --fork --pid --mount-proc --net --uts --mount /bin/bash &
    sleep 1
    pid=$!

    # Enter the new namespaces
    nsenter --target $pid --uts --mount --net --pid /bin/bash <<EOF
    # Set the hostname
    hostname $hostname

    # Mount the new filesystem
    mkdir -p /mnt/oldroot
    mount --bind $UBUNTU_ROOTFS_PATH /mnt
    pivot_root /mnt /mnt/oldroot

    # Unmount the old root
    umount /mnt/oldroot
    rmdir /mnt/oldroot

    # Apply memory limit if specified
    if [ ! -z "$memory_limit" ]; then
        mkdir -p /sys/fs/cgroup/memory/container
        echo $((memory_limit * 1024 * 1024)) > /sys/fs/cgroup/memory/container/memory.limit_in_bytes
        echo $$ > /sys/fs/cgroup/memory/container/cgroup.procs
    fi

    # Start a new bash shell in the container
    exec /bin/bash
EOF
}

if [ $# -lt 1 ]; then
    echo "Usage: $0 <hostname> [memory_limit]"
    exit 1
fi

hostname=$1
memory_limit=$2
create_container $hostname $memory_limit

