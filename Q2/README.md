# Simple Container Runtime

## Description
This is a simple container runtime implemented in Python. It uses namespaces to isolate the container's process, network, and mount points. The root filesystem of the container is an Ubuntu 20.04 filesystem.

## Features
- Creates new namespaces: net, mnt, pid, uts
- Separate root filesystem
- Optionally limits memory usage

## Usage
1. Ensure you have the Ubuntu 20.04 filesystem prepared:
    ```bash
    mkdir /ubuntu_rootfs
    cd /ubuntu_rootfs
    sudo tar -xpf /path/to/ubuntu-20.04-base.tar.gz
    ```

2. Run the CLI:
    ```bash
    ./mycli.py <hostname> [memory_limit_in_MB]
    ```

### Example
```bash
./mycli.py myhostname 100

