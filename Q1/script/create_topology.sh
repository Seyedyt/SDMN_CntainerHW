#!/bin/bash

# Create namespaces
ip netns add node1
ip netns add node2
ip netns add node3
ip netns add node4
ip netns add router

# Create veth pairs
ip link add veth1 type veth peer name veth1-br
ip link add veth2 type veth peer name veth2-br
ip link add veth3 type veth peer name veth3-br
ip link add veth4 type veth peer name veth4-br
ip link add veth-router1 type veth peer name veth-router1-br
ip link add veth-router2 type veth peer name veth-router2-br

# Assign veth pairs to namespaces
ip link set veth1 netns node1
ip link set veth2 netns node2
ip link set veth3 netns node3
ip link set veth4 netns node4
ip link set veth-router1 netns router
ip link set veth-router2 netns router

# Create bridges
ip link add br1 type bridge
ip link add br2 type bridge

# Attach veth pairs to bridges
ip link set veth1-br master br1
ip link set veth2-br master br1
ip link set veth-router1-br master br1
ip link set veth3-br master br2
ip link set veth4-br master br2
ip link set veth-router2-br master br2

# Assign IP addresses
ip netns exec node1 ip addr add 172.0.0.2/24 dev veth1
ip netns exec node2 ip addr add 172.0.0.3/24 dev veth2
ip netns exec node3 ip addr add 10.10.0.2/24 dev veth3
ip netns exec node4 ip addr add 10.10.0.3/24 dev veth4
ip netns exec router ip addr add 172.0.0.1/24 dev veth-router1
ip netns exec router ip addr add 10.10.0.1/24 dev veth-router2

# Bring up interfaces and bridges
ip link set br1 up
ip link set br2 up
ip link set veth1-br up
ip link set veth2-br up
ip link set veth-router1-br up
ip link set veth3-br up
ip link set veth4-br up
ip link set veth-router2-br up
ip netns exec node1 ip link set veth1 up
ip netns exec node2 ip link set veth2 up
ip netns exec node3 ip link set veth3 up
ip netns exec node4 ip link set veth4 up
ip netns exec router ip link set veth-router1 up
ip netns exec router ip link set veth-router2 up

# Set default routes
ip netns exec node1 ip route add default via 172.0.0.1
ip netns exec node2 ip route add default via 172.0.0.1
ip netns exec node3 ip route add default via 10.10.0.1
ip netns exec node4 ip route add default via 10.10.0.1

# Enable IP forwarding on router
ip netns exec router sysctl -w net.ipv4.ip_forward=1

