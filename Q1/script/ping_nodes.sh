#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source_node> <destination_node>"
    exit 1
fi

SOURCE=$1
DEST=$2

# Determine the IP address of the destination
case $DEST in
    router)
        if [ "$SOURCE" == "node1" ] || [ "$SOURCE" == "node2" ]; then
            DEST_IP="172.0.0.1"
        elif [ "$SOURCE" == "node3" ] || [ "$SOURCE" == "node4" ]; then
            DEST_IP="10.10.0.1"
        fi
        ;;
    node1)
        DEST_IP="172.0.0.2"
        ;;
    node2)
        DEST_IP="172.0.0.3"
        ;;
    node3)
        DEST_IP="10.10.0.2"
        ;;
    node4)
        DEST_IP="10.10.0.3"
        ;;
    *)
        echo "Unknown destination: $DEST"
        exit 1
        ;;
esac

# Execute the ping command in the source namespace
sudo ip netns exec $SOURCE ping -c 4 $DEST_IP

