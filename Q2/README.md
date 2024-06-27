# Simple Container Runtime CLI

This project implements a simple container runtime CLI that creates a container with new namespaces and a separate root filesystem.

## Features

- Creates new namespaces for the container: net, mnt, pid, uts
- Sets a custom hostname for the container
- Uses a separate root filesystem for the container (`/ubuntu_rootfs`)
- Optionally limits the memory usage of the container

## Requirements

- Python 3.x
- `unshare` command (part of the `util-linux` package)
- Root privileges (to create namespaces and change the root filesystem)

## Setup

1. Ensure you have Python 3 installed on your system.
2. Install `unshare` if it is not already installed:
   ```bash
   sudo apt-get install util-linux
3. Make sure you have Ubuntu 20.04 filesystem extracted to '/	    ubuntu_rootfs'. You can download and extract it using the following commands:
   ```bash
   sudo mkdir -p /ubuntu_rootfs
   sudo tar -xzf ubuntu-20.04-rootfs.tar.gz -C /ubuntu_rootfs

## Usage

1. Clone this repository and navigate to the directory containing the script.

2. make sure the script executable:
   ```bash
   chmod +x mycli.py
   
3. Run the script with the desired hostname and optional memory limit (in MB):
   ```bash
   sudo ./mycli.py <hostname> [memmory_limit_in_MB]
   
## verifying the container
Once the script is run, you will be inside a bash shell in the new container environment. You can verify that the container is correctly set up by performing the following checks:

1. Check the Hostname:
Run the following command:

   ```bash
   hostname

This should output the hostname you specified (e.g., myhostname). This confirms that the UTS namespace is correctly set up.

2. List Running Processes:
   To verify the PID namespace, run:

   ```bash
   ps fax

   This should show /bin/bash running as PID 1. The PID 1 process in a container is typically the first process and serves as the init system for that container.
   
3. Check the Filesystem:
   To confirm that the root filesystem is correctly set up, run:

   ```bash
   ls /

   This should display the root filesystem structure from the Ubuntu 20.04 filesystem. It should not reflect the host system’s root filesystem.
   
4. Check the Memory Limit (if specified):
  If you specified a memory limit, you can check if it's enforced by looking at the memory cgroup settings:

   ```bash
   cat /sys/fs/cgroup/memory/<hostname>/memory.limit_in_bytes

   Replace <hostname> with the hostname you specified. This should output the memory limit in bytes, confirming that the memory cgroup is correctly set up.
   
   
## Exiting the Container
To exit the container and return to your host system, simply type:

   ```bash
   exit

This will close the bash shell running inside the container and bring you back to the host system's shell.

