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
function finish_line { white_echo "OK"; }

## Sets correct permissions for .ssh directory and its contents.
## This script takes the user that the directory belongs to as the first argument.

usr="$1"

if [[ ${usr} == "" ]]; then
  echo "Usage:"
  echo "./$0 \$USER"
fi

# At this moment, these are the minimum permissions
# for each file and folder listed here.
declare -a SET_PERMS
SET_PERMS=( "chown ${usr}:${usr} -R   /home/${usr}/.ssh"                 \
            "chown ${usr}:${usr}      /home/${usr}"                      \
            "chmod 0700               /home/${usr}/.ssh"                 \
            "chmod 0400               /home/${usr}/.ssh/config"          \
            "chmod 0600               /home/${usr}/.ssh/authorized_keys" \
            "chmod 0644               /home/${usr}/.ssh/id_rsa.pub"      \
            "chmod 0400               /home/${usr}/.ssh/id_rsa"          \
          )

function setPerms {
  for item in "${SET_PERMS[@]}"; do    
    local column_two="$(printf "${item}" | awk '{print $2}')"
    local column_three="$(printf "${item}" | awk '{print $3}')"
    local column_four="$(printf "${item}" | awk '{print $4}')"
    silence "${item}"
    if [[ $? == 0 ]]; then
      if [[ ${item} =~ "chown" && ${item} =~ "-R" ]]; then
        echoInfo "Set ${column_two} as owner of ${column_four}"
      else
        echoInfo "Set ${column_two} permission for ${column_three}"
      fi
    elif [ ! -e ${column_three} ] || [ ! -e ${column_four} ]; then
      if [[ ${item} =~ "chown" && ${item} =~ "-R" ]]; then
        echoWarn "${column_four} not found!"
      else
        echoWarn "${column_three} not found!"
      fi
    else
      if [[ ${item} =~ "chown" && ${item} =~ "-R" ]]; then
        echoError "Failed to set ${column_two} as owner of ${column_four}"
      else
        echoError "Failed to set ${column_two} permission for ${column_three}"
      fi
    fi
  done
}

setPerms
finish_line