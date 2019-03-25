#!/bin/bash
# See LICENSE.
# Copyright (C) 2019 Akito


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

# Install dependencies.
apt install -y wget git build-essential

# Get go1.4 toolchain bootstrap source code.
mkdir ~/src
cd ~/src
mkdir go1.4-bootstrap-20171003
cd go1.4-bootstrap-20171003
wget https://dl.google.com/go/go1.4-bootstrap-20171003.tar.gz
tar zxvf go1.4-bootstrap-20171003.tar.gz --strip-components 1
rm go1.4-bootstrap-20171003.tar.gz
cd src

# Compile go1.4 toolchain.
CGO_ENABLED=0
echo -e "Compiling first toolchain now. This may take some time."
./make.bash
cd ../..

# Get go1.11.2 for the host system assuming the host system is of the amd64 architecture
mkdir go1.11.2
cd go1.11.2
wget https://dl.google.com/go/go1.11.2.linux-amd64.tar.gz
tar zxvf go1.11.2.linux-amd64.tar.gz --strip-components 1
rm go1.11.2.linux-amd64.tar.gz
cd src

# Set environment variables and compile go1.11.2 toolchain
export GOROOT_BOOTSTRAP="$HOME/src/go1.4-bootstrap-20171003"
echo -e "Compiling second toolchain now. This may take some time."
GOOS=linux GOARCH=arm ./bootstrap.bash
cd ../..

echo -e "Now you are in ~/src where the directory go-linux-arm-bootstrap folder is created,\nwhich you need to proceed to the next part. Use the README.md\nor go1.11.2_arm_bootstrap.sh to proceed as needed."

exit 0