# SDMN Container Homework

## Overview
This repository contains solutions for the SDMN container homework. It includes scripts for creating network namespaces and setting up network topologies, as well as documentation on routing between different topologies.

## Directory Structure
- `script/`
  - `create_topology.sh`: Script to create the network namespace topology as shown in Figure 1.
  - `ping_nodes.sh`: Script to ping between nodes.
- `docs/`
  - `routing_without_router.md`: Explanation of routing packets without a router (Figure 2).
  - `routing_between_servers.md`: Explanation of routing between namespaces on different servers (Figure 3).

## Usage
1. **Create Topology**:
   ```bash
   sudo ./script/create_topology.sh

