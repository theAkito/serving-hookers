#!/bin/bash
# See LICENSE.
# Copyright (C) 2019 Akito

# Clone the repository and set GOROOT_BOOTSTRAP environment variable.
mkdir ~/src ;
cd ~/src && \
git clone https://github.com/Akito13/go1.11.2_arm_bootstrap.git
export GOROOT_BOOTSTRAP=$HOME/src/go1.11.2_arm_bootstrap/go-linux-arm-bootstrap

# Retrieving Go source code.
mkdir go1.12.1
cd go1.12.1
git clone https://go.googlesource.com/go . && \
cd src

# Comment this out to use the newest Go version.
git checkout go1.12.1

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

if ! [[ $(./go run hello.go > /dev/null 2>&1)$? ]]; then
    echo -e "Test failed. Please re-execute the script or check for other issues. Exiting."
    exit 1
else
    echo -e "Go successfully installed and working!"
fi

# Setting environment ready to Go.
export PATH="$PATH:$HOME/src/go1.12.1/bin" && \
export GOPATH=$HOME/go

# Checking if PATH is set correctly.
if ! [[ $(go version > /dev/null 2>&1)$? ]]; then
    echo -e "Setting PATH failed. You can execute Go locally but not globally."
else
    echo -e "Go successfully set in PATH. Go can now be run globally."
fi

echo -e "Go has been successfully compiled, installed and set in PATH, so your system is now ready to Go!"

exit 0