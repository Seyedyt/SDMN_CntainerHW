# Routing Without Router (Figure 2)

To route packets between subnets without a router, we can use the following approach:

1. **Bridge Setup**: Connect the two bridges `br1` and `br2` directly.
2. **IP Forwarding**: Enable IP forwarding on the bridges to allow traffic to pass between the subnets.

### Steps:

1. **Create veth pair between bridges**:
    ```bash
    ip link add br-link1 type veth peer name br-link2
    ip link set br-link1 master br1
    ip link set br-link2 master br2
    ip link set br-link1 up
    ip link set br-link2 up
    ```

2. **Enable IP forwarding**:
    ```bash
    sysctl -w net.ipv4.ip_forward=1
    ```

This setup allows packets to be forwarded between the two subnets through the linked bridges.

