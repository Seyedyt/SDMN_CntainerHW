#!/bin/bash

create_container() {
    hostname=$1
    echo "Creating container with hostname: $hostname"
    unshare --fork --pid --mount-proc --net --uts --mount /bin/bash &
    sleep 1
    pid=$!
    echo "Setting hostname"
    nsenter --target $pid --uts --hostname $hostname
    echo "Entering new namespace"
    nsenter --target $pid --all /bin/bash
}

if [ $# -lt 1 ]; then
    echo "Usage: $0 <hostname>"
    exit 1
fi

hostname=$1
create_container $hostname

