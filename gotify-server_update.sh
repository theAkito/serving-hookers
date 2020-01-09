#!/bin/bash
# See LICENSE.
# Copyright (C) 2019 Akito
# This script has only been successfully on a Debian based OS.
# If you want to have support for other bases, then create a pull request as described in README.md.

# Backing up old gotify-server folder and cloning new one.
	cd ~/src/ && \
    mv gotify-server gotify-server-old && \
    git clone https://github.com/gotify/server.git gotify-server && \
    cd gotify-server && \
    
# Getting dependencies and setting up build environment.
    make download-tools && \
    go get -d && \
    cd ui && \
    npm install && \
    npm run build && \
    packr && \
    cd .. && \
    
# Building gotify-server without using docker.
    export LD_FLAGS="-w -s -X main.Version=$(git describe --tags | cut -c 2-) -X main.BuildDate=$(date "+%F-%T") -X main.Commit=$(git rev-parse --verify HEAD) -X main.Mode=prod"; && \
    go build -ldflags="$LD_FLAGS" -o gotify-server && \
    
# Copying persistent data from previous gotify-server installation.
	cd .. && \
    cp gotify-server-old/data/gotify.db gotify-server/data/gotify.db && \
    cp -r gotify-server-old/data/certs gotify-server/data/ && \
    cp gotify-server-old/config.yml gotify-server/config.yml && \
    
    echo -e "\nUpdated gotify-server successfully."
    echo -e "Old version has been moved to gotify-server-old."