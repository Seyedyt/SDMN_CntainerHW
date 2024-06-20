#!/usr/bin/env python3

import os
import sys
import subprocess

def setup_rootfs(new_root):
    # Ensure the new root filesystem exists
    if not os.path.exists(new_root):
        raise FileNotFoundError(f"The specified root filesystem {new_root} does not exist")

    # Bind mount the new root to itself to make it private
    subprocess.run(["mount", "--bind", new_root, new_root], check=True)
    subprocess.run(["mount", "--make-private", new_root], check=True)

    # Change to the new root directory
    os.chdir(new_root)

    # Move the old root to a temporary location
    old_root = os.path.join(new_root, ".old_root")
    os.mkdir(old_root)
    subprocess.run(["pivot_root", new_root, old_root], check=True)

    # Unmount the old root and remove the directory
    subprocess.run(["umount", "-l", old_root], check=True)
    os.rmdir(old_root)

def main():
    if len(sys.argv) < 2:
        print("Usage: mycli <hostname> [memory_limit_in_MB]")
        sys.exit(1)

    hostname = sys.argv[1]
    memory_limit = int(sys.argv[2]) if len(sys.argv) > 2 else None
    new_root = "/ubuntu_rootfs"  # Use the provided path for the root filesystem

    # Unshare namespaces
    unshare_flags = os.CLONE_NEWNET | os.CLONE_NEWNS | os.CLONE_NEWPID | os.CLONE_NEWUTS
    subprocess.run(["unshare", "--fork", "--pid", "--mount-proc", "--mount", "--uts", "--net", "/usr/bin/env", "python3", __file__, "child"] + sys.argv[1:], check=True)

def child_main():
    hostname = sys.argv[2]
    memory_limit = int(sys.argv[3]) if len(sys.argv) > 3 else None
    new_root = "/ubuntu_rootfs"

    # Set the hostname
    os.sethostname(hostname)

    # Setup new root filesystem
    setup_rootfs(new_root)

    # Limit memory usage (if specified)
    if memory_limit:
        cgroup_path = f"/sys/fs/cgroup/memory/{hostname}"
        os.makedirs(cgroup_path, exist_ok=True)
        with open(os.path.join(cgroup_path, "memory.limit_in_bytes"), "w") as f:
            f.write(f"{memory_limit * 1024 * 1024}")
        with open(os.path.join(cgroup_path, "tasks"), "w") as f:
            f.write(str(os.getpid()))

    # Execute bash in the new namespace
    os.execv("/bin/bash", ["/bin/bash"])

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "child":
        child_main()
    else:
        main()

