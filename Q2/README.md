# Simple Container Runtime CLI

## Setup

1. **Download and Extract Ubuntu 20.04 Root Filesystem:**

   - Pull the Ubuntu 20.04 image from DockerHub:

     ```bash
     docker pull ubuntu:20.04
     ```

   - Create a container from the image and export its filesystem:

     ```bash
     docker create --name ubuntu-container ubuntu:20.04
     docker export ubuntu-container > ubuntu-rootfs.tar
     docker rm ubuntu-container
     ```

   - Create a directory to extract the filesystem:

     ```bash
     mkdir -p /path/to/ubuntu-rootfs
     ```

   - Extract the tarball into the directory:

     ```bash
     tar -C /path/to/ubuntu-rootfs -xf ubuntu-rootfs.tar
     ```

   - Verify the extraction:

     ```bash
     ls /path/to/ubuntu-rootfs
     ```

2. **Update `cli.sh` Script:**

   - Set the `UBUNTU_ROOTFS_PATH` variable in `cli.sh` to the path where you extracted the filesystem:

     ```bash
     UBUNTU_ROOTFS_PATH="/path/to/ubuntu-rootfs"  # Change this to the actual path
     ```

## Usage

```bash
./cli.sh <hostname> [memory_limit]
