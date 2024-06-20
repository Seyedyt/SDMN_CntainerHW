#!/bin/bash

create_container() {
    hostname=$1
    echo "Creating container with hostname: $hostname"
    # Logic to create container will go here
}

if [ $# -lt 1 ]; then
    echo "Usage: $0 <hostname>"
    exit 1
fi

hostname=$1
create_container $hostname
