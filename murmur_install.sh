#!/bin/bash
#########################################################################
# Copyright (C) 2020 Akito <the@akito.ooo>                              #
#                                                                       #
# This program is free software: you can redistribute it and/or modify  #
# it under the terms of the GNU General Public License as published by  #
# the Free Software Foundation, either version 3 of the License, or     #
# (at your option) any later version.                                   #
#                                                                       #
# This program is distributed in the hope that it will be useful,       #
# but WITHOUT ANY WARRANTY; without even the implied warranty of        #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the          #
# GNU General Public License for more details.                          #
#                                                                       #
# You should have received a copy of the GNU General Public License     #
# along with this program.  If not, see <http://www.gnu.org/licenses/>. #
#########################################################################
function white_echo { echo -e "\033[1;37m$@\033[0m"; }
function OK { white_echo "OK"; }
tmp_loc="/tmp/mumble-src"
mkdir "${tmp_loc}"
cd "${tmp_loc}"
git clone https://github.com/mumble-voip/mumble.git .
apt-get update -qq
apt-get install -y -qq \
                build-essential \
                pkg-config \
                qt5-default \
                qttools5-dev-tools \
                libqt5svg5-dev \
                libboost-dev \
                libasound2-dev \
                libssl-dev \
                libspeechd-dev \
                libzeroc-ice-dev \
                libpulse-dev \
                libcap-dev \
                libprotobuf-dev \
                protobuf-compiler \
                libogg-dev \
                libavahi-compat-libdnssd-dev \
                libsndfile1-dev \
                libxi-dev 
qmake main.pro CONFIG+=no-client CONFIG+=optimize CONFIG+=no-update
make release
apt-get remove -y -qq \
                qt5-default \
                qttools5-dev-tools \
                libqt5svg5-dev \
                libboost-dev \
                libasound2-dev \
                libssl-dev \
                libspeechd-dev \
                libzeroc-ice-dev \
                libpulse-dev \
                libcap-dev \
                libprotobuf-dev \
                protobuf-compiler \
                libogg-dev \
                libavahi-compat-libdnssd-dev \
                libsndfile1-dev \
                libxi-dev 
mv release/murmurd /usr/bin/murmurd
cd ~
rm -fr "${tmp_loc}"
useradd --system mumble-server
OK
