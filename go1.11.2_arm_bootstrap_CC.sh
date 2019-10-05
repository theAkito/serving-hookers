#!/bin/bash
# See LICENSE.
# Copyright (C) 2019 Akito

# Get go1.4 toolchain bootstrap source code.
mkdir ~/src > /dev/null 2>&1
cd ~/src
mkdir go1.4-bootstrap-20171003
cd go1.4-bootstrap-20171003
wget https://dl.google.com/go/go1.4-bootstrap-20171003.tar.gz > /dev/null 2>&1
tar zxf go1.4-bootstrap-20171003.tar.gz --strip-components 1 > /dev/null 2>&1
rm go1.4-bootstrap-20171003.tar.gz
cd src

# Compile go1.4 toolchain.
CGO_ENABLED=0
echo -e "Compiling first toolchain now. This may take some time."
./make.bash > /dev/null 2>&1 && \
cd ../..

# Get go1.11.2 for the host system assuming the host system is of the amd64 architecture
mkdir go1.11.2
cd go1.11.2
wget https://dl.google.com/go/go1.11.2.linux-amd64.tar.gz > /dev/null 2>&1
tar zxf go1.11.2.linux-amd64.tar.gz --strip-components 1 > /dev/null 2>&1
rm go1.11.2.linux-amd64.tar.gz
cd src

# Set environment variables and compile go1.11.2 toolchain
export GOROOT_BOOTSTRAP="$HOME/src/go1.4-bootstrap-20171003"
echo -e "Compiling second toolchain now. This may take some time."
GOOS=linux GOARCH=arm ./bootstrap.bash > /dev/null 2>&1 && \
cd ../..

echo -e "Now you are in ~/src where the directory go-linux-arm-bootstrap is created,"
echo -e "which you need to proceed to the next part. Use the README.md"
echo -e "or go1.13.1_arm_bootstrap.sh to proceed as needed."

exit 0