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
#
#################################   Boilerplate of the Boilerplate   ####################################################
# Coloured Echoes                                                                                                       #
function red_echo      { echo -e "\033[31m$@\033[0m";   }                                                               #
function green_echo    { echo -e "\033[32m$@\033[0m";   }                                                               #
function yellow_echo   { echo -e "\033[33m$@\033[0m";   }                                                               #
function white_echo    { echo -e "\033[1;37m$@\033[0m"; }                                                               #
# Coloured Printfs                                                                                                      #
function red_printf    { printf "\033[31m$@\033[0m";    }                                                               #
function green_printf  { printf "\033[32m$@\033[0m";    }                                                               #
function yellow_printf { printf "\033[33m$@\033[0m";    }                                                               #
function white_printf  { printf "\033[1;37m$@\033[0m";  }                                                               #
# Debugging Outputs                                                                                                     #
function getCurrentTime { printf '%s' "$(date +'%Y-%m-%dT%H:%M:%S%Z')"; }                                               #
function white_brackets { local args="$@"; white_printf "["; printf "${args}"; white_printf "]"; }                      #
function echoDebug  { local args="$@"; if [[ ${debug_flag} == true ]]; then                                             #
white_brackets "$(white_printf   "DEBUG")" && echo " ${args}"; fi; }                                                    #
function echoInfo   { local args="$@"; white_brackets "$(green_printf  "INFO" )"  && echo " ${args}"; }                 #
function echoWarn   { local args="$@"; white_brackets "$(yellow_printf "WARN" )"  && echo " ${args}" 1>&2; }            #
function echoError  { local args="$@"; white_brackets "$(red_printf    "ERROR")"  && echo " ${args}" 1>&2; }            #
function log { printf '%s%s\n' "$(getCurrentTime): " "$@"; }                                                            #
# Silences commands' STDOUT as well as STDERR.                                                                          #
function silence { local args="$@"; ${args} &>/dev/null; }                                                              #
# Check your privilege.                                                                                                 #
function checkPriv { if [[ "$EUID" != 0 ]]; then echoError "Please run me as root."; exit 1; fi;  }                     #
# Returns 0 if script is sourced, returns 1 if script is run in a subshell.                                             #
function checkSrc { (return 0 2>/dev/null); if [[ "$?" == 0 ]]; then return 0; else return 1; fi; }                     #
# Prints directory the script is run from. Useful for local imports of BASH modules.                                    #
# This only works if this function is defined in the actual script. So copy pasting is needed.                          #
function whereAmI { printf "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )";   }                     #
# Alternatively, this alias works in the sourcing script, but you need to enable alias expansion.                       #
alias whereIsMe='printf "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"'                            #
debug_flag=false                                                                                                        #
#########################################################################################################################

if  [[ \
       $(go version | grep 'go[1-9]\.[1-9][0-9].*.*' > /dev/null 2>&1)$? == 0 || \
       $(go version | grep 'go[1-9]\.[5-9].*.*'      > /dev/null 2>&1)$? == 0    \
    ]]; then
    :
else
    white_echo "Go version too low or not installed. Please install Go version 1.5 or higher. Exiting.";
    echo
    white_echo "If using Raspberry Pi, you are welcome to use the following script:";
    white_echo "https://github.com/theAkito/serving-hookers/blob/master/go1.13.1_arm_bootstrap.sh";
    echo
    white_echo "Download directly by executing the following line: "
    white_echo "wget -q https://raw.githubusercontent.com/theAkito/serving-hookers/master/go1.13.1_arm_bootstrap.sh"
    exit 1
fi

if [ -z "$GOPATH" ]; then
    echoError  '$GOPATH not set.'
    white_echo 'Set $GOPATH like:'
    white_echo 'GOPATH=/home/$USER/go'
    exit 1
fi

# Getting and installing micro.
silence "mkdir -p $GOPATH/src/github.com/zyedidia"            && \
silence "cd $GOPATH/src/github.com/zyedidia"                  && \
silence "git clone https://github.com/zyedidia/micro.git"     && \
build-all                                                     && \
mv micro ${GOPATH}/bin/micro

if ! [[ $($GOPATH/bin/micro --version > /dev/null 2>&1)$? == 0 ]]; then
    echo -e "Something went wrong with the installation. Exiting."
    exit 1
else
    sudo ln -sf $GOPATH/bin/micro /usr/bin/micro
    echoInfo "Symbolic link from $GOPATH/bin/micro to /usr/bin/micro created."
    white_echo "Micro installed successfully!"
    exit 0
fi
