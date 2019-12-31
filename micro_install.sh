#!/bin/bash
# See LICENSE.
# Copyright (C) 2019 Akito <the@akito.ooo>

if  [[ \
       $(go version | grep 'go[1-9]\.[1-9][0-9].*.*' > /dev/null 2>&1)$? == 0 || \
       $(go version | grep 'go[1-9]\.[5-9].*.*'      > /dev/null 2>&1)$? == 0    \
    ]]; then
    :
else
    echo "Go version too low or not installed. Please install Go version 1.5 or higher. Exiting.";
    echo
    echo "If using Raspberry Pi, you are welcome to use the following script:";
    echo "https://github.com/theAkito/serving-hookers/blob/master/go1.13.1_arm_bootstrap.sh";
    echo
    echo "Download directly by executing the following line: "
    echo "wget -q https://raw.githubusercontent.com/theAkito/serving-hookers/master/go1.13.1_arm_bootstrap.sh"
    exit 1
fi

if [ -z "$GOPATH" ]; then
    echo '$GOPATH not set.'
    echo 'Set $GOPATH like:'
    echo '$GOPATH=/home/$USER/go'
fi

# Getting and installing micro.
go get -d github.com/zyedidia/micro/...  >/dev/null && \
cd $GOPATH/src/github.com/zyedidia                  && \
make install


if ! [[ $($GOPATH/bin/micro --version > /dev/null 2>&1)$? == 0 ]]; then
    echo -e "Something went wrong with the installation. Exiting."
    exit 1
else
    sudo ln -s $GOPATH/bin/micro /usr/bin/micro
    echo -e "Micro installed successfully!"
    echo -e "Symbolic link from $GOPATH/bin/micro to /usr/bin/micro created."
    exit 0
fi