#!/bin/bash
# See LICENSE.
# Copyright (C) 2019 Akito

# Clone the repository and set GOROOT_BOOTSTRAP environment variable.
mkdir ~/src > /dev/null 2>&1 ;
cd ~/src && \
git clone https://github.com/Akito13/go1.11.2_arm_bootstrap.git
GOROOT_BOOTSTRAP=$HOME/src/go1.11.2_arm_bootstrap/go-linux-arm-bootstrap

# Retrieving Go source code.
mkdir go                                   && \
cd go                                      && \
git clone https://go.googlesource.com/go . && \
cd src

# Comment this out to use the newest Go version.
git checkout go1.13.1

# Compiling target Go for Raspberry Pi.
echo -e "Compiling Go for Raspberry Pi now."
echo -e "This may take some time, please be patient."
./make.bash

# Testing Go installation.
cd ..
cd bin
cat > hello.go << "EOF"
package main

import "fmt"

func main() {

        fmt.Printf("GO-reetings!\n")

}
EOF

if ! [[ $(./go run hello.go > /dev/null 2>&1)$? == 0 ]]; then
    echo -e "Running Go locally failed. Please re-execute the script or check for other issues. Exiting."
    exit 1
else
    echo -e "Go is working locally, now!"
    echo -e "Now make Go available system-wide"
    echo -e "by running the following commands:"
    echo
    echo -e 'export PATH="$PATH:$HOME/src/go/bin"'
    echo -e 'export GOPATH="HOME/go"'
    echo -e "or"
    echo -e "source go_path.sh"
fi

exit 0