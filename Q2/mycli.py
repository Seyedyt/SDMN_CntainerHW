#!/usr/bin/env python3

import os
import sys
import subprocess

def setup_rootfs(new_root):
    if not os.path.exists(new_root):
        raise FileNotFoundError(f"The specified root filesystem {new_root} does not exist")

    print(f"Changing root to the new filesystem: {new_root}")
    try:
        subprocess.run(["chroot", new_root], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Failed to change root: {e}")
        sys.exit(1)

def main():
    if len(sys.argv) < 2:
        print("Usage: mycli <hostname> [memory_limit_in_MB]")
        sys.exit(1)

    hostname = sys.argv[1]
    memory_limit = int(sys.argv[2]) if len(sys.argv) > 2 else None
    new_root = "/ubuntu_rootfs"

    print(f"Creating new namespaces and executing the child process")
    try:
        subprocess.run(["unshare", "--fork", "--pid", "--mount-proc", "--mount", "--uts", "--net", "/usr/bin/env", "python3", __file__, "child"] + sys.argv[1:], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Failed to create new namespaces: {e}")
        sys.exit(1)

def child_main():
    hostname = sys.argv[2]
    memory_limit = int(sys.argv[3]) if len(sys.argv) > 3 else None
    new_root = "/ubuntu_rootfs"

    print(f"Setting hostname to {hostname}")
    try:
        subprocess.run(["hostname", hostname], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Failed to set hostname: {e}")
        sys.exit(1)

    setup_rootfs(new_root)

    if memory_limit:
        cgroup_path = f"/sys/fs/cgroup/memory/{hostname}"
        print(f"Setting memory limit to {memory_limit} MB in cgroup: {cgroup_path}")
        os.makedirs(cgroup_path, exist_ok=True)
        with open(os.path.join(cgroup_path, "memory.limit_in_bytes"), "w") as f:
            f.write(f"{memory_limit * 1024 * 1024}")
        with open(os.path.join(cgroup_path, "tasks"), "w") as f:
            f.write(str(os.getpid()))

    print("Executing bash shell in the new container")
    os.execv("/bin/bash", ["/bin/bash"])

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "child":
        child_main()
    else:
        main()

