# Routing Between Different Servers (Figure 3)

When namespaces are on different servers, routing can be achieved using a tunnel, such as a GRE tunnel, between the servers.

### Steps:

1. **Create GRE Tunnel**:
    ```bash
    # On Server 1
    ip tunnel add gre1 mode gre remote <Server2_IP> local <Server1_IP> ttl 255
    ip link set gre1 up
    ip addr add 192.168.1.1/24 dev gre1
    
    # On Server 2
    ip tunnel add gre2 mode gre remote <Server1_IP> local <Server2_IP> ttl 255
    ip link set gre2 up
    ip addr add 192.168.1.2/24 dev gre2
    ```

2. **Routing Rules**:
    - On Server 1, add routes to the subnets on Server 2 through the GRE tunnel.
    - On Server 2, add routes to the subnets on Server 1 through the GRE tunnel.
    ```bash
    # On Server 1
    ip route add 10.10.0.0/24 via 192.168.1.2
    
    # On Server 2
    ip route add 172.0.0.0/24 via 192.168.1.1
    ```

This setup ensures that packets can be routed between different servers using a GRE tunnel.

