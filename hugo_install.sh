#!/bin/bash
# See LICENSE.
# Copyright (C) 2019 Akito

# Check if Go version is recent enough.
if ! [[ $(go version | grep 'go1\.1[2-9].*.*') ]]; then
    echo "Go version too low or not installed. Please install Go version 1.11.2 or higher. Exiting.";
    echo
    echo "If using Raspberry Pi, you are welcome to use the following script:";
    echo "https://github.com/Akito13/serving-hookers/blob/master/go1.11.2_arm_bootstrap.sh";
    echo
    echo "Download directly by executing the following line: "
    echo "wget -q https://raw.githubusercontent.com/Akito13/serving-hookers/master/go1.11.2_arm_bootstrap.sh"
    exit 1
fi

# Cloning Hugo master and installing.
mkdir $HOME/src
cd $HOME/src
git clone https://github.com/gohugoio/hugo.git
cd hugo
# Remove "--tags extended" if you do not want Sass/SCSS support.
go install --tags extended && \
echo -e "Successfully installed Hugo with extensions.";

exit 0
