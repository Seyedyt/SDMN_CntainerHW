#!/usr/bin/env python3

import os
import sys
import subprocess

def setup_rootfs(new_root):
    if not os.path.exists(new_root):
        raise FileNotFoundError(f"The specified root filesystem {new_root} does not exist")

    print(f"Binding and making private the new root: {new_root}")
    subprocess.run(["mount", "--bind", new_root, new_root], check=True)
    subprocess.run(["mount", "--make-private", new_root], check=True)

    os.chdir(new_root)

    old_root = os.path.join(new_root, ".old_root")
    if not os.path.exists(old_root):
        os.mkdir(old_root)

    print(f"Pivoting root from {new_root} to {old_root}")
    try:
        subprocess.run(["pivot_root", new_root, old_root], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Failed to pivot root: {e}")
        sys.exit(1)

    print

