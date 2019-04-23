#!/bin/bash
# See LICENSE.
# Copyright (C) 2019 Akito

if ! [[ $(go version | grep 'go[1-9]\.[1-9][0-9].*.*') || $(go version | grep 'go[1-9]\.[5-9].*.*') ]]; then
    echo "Go version too low or not installed. Please install Go version 1.5 or higher. Exiting.";
    echo
    echo "If using Raspberry Pi, you are welcome to use the following script:";
    echo "https://github.com/Akito13/serving-hookers/blob/master/go1.11.2_arm_bootstrap.sh";
    exit 1
fi

# Getting and installing micro.
export GO111MODULES=off && \
export GOROOT="" && \
go get -d github.com/zyedidia/micro/... && \
cd $GOPATH/src/github.com/zyedidia/micro && \
make install && \
export PATH="$PATH:/home/$USER/go/bin"

if ! [[ $(micro --version > /dev/null 2>&1)$? ]]; then
    echo -e "Something went wrong with the installation. Exiting."
else
    echo -e "Micro installed successfully!"
fi

exit 0