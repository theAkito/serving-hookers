#!/bin/bash
# See LICENSE.
# Copyright (C) 2019 Akito
# Made to be compatible with armv6+ Raspberry Pis running Raspbian Stretch based systems, such as DietPi.

# Check if user is "root".
 echo -e "\033[1;33mAm I run as root user?\033[0m\n"
 if [[ "$EUID" != 0 ]]; then
     echo -e "\033[1;33mNo. Please run me as root user.\033[0m"
     sleep 3
     echo -e "\033[1;33m.\033[0m"
     sleep 1
     echo -e "\033[1;33m.\033[0m"
     sleep 1
     echo -e "\033[1;33m.\033[0m"
     sleep 1
     exit 1
else
     echo -e "\n\033[1;33mYes! I am run as root user.\033[0m"
fi

# Install pre-dependencies.
echo "Installing kernel headers now. This can take a very long time.";
apt install -y raspberrypi-kernel-headers > /dev/null 2>&1

# Getting custom APT repositories and installing them.
wget https://m.eshug.ga/rep/key/arep.sh -qO /tmp/arep.sh && \
chmod +x /tmp/arep.sh && \
bash /tmp/arep.sh && \
rm /tmp/arep.sh
apt update > /dev/null 2>&1

# Install ZFS and its direct dependencies.
apt install -t stretch-backports -y libuutil1linux libnvpair1linux libzpool2linux libzfs2linux zfsutils-linux spl-dkms zfs-dkms > /dev/null 2>&1

# Check if zpool command works. If it works, ZFS is working.
if ! [[ $(zpool status > /dev/null 2>&1) ]]; then
    echo "Something went wrong during the execution of this script. Exiting.";
    exit 1
else
	echo "Congratulations, ZFS on Linux is now set up ready to be used on your Raspberry Pi.";
fi

exit 0