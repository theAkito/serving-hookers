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
#################################   Boilerplate of the Boilerplate   #################################
# Coloured Echoes                                                                                    #
function red_echo      { echo -e "\033[31m$@\033[0m";   }                                            #
function green_echo    { echo -e "\033[32m$@\033[0m";   }                                            #
function yellow_echo   { echo -e "\033[33m$@\033[0m";   }                                            #
function white_echo    { echo -e "\033[1;37m$@\033[0m"; }                                            #
# Coloured Printfs                                                                                   #
function red_printf    { printf "\033[31m$@\033[0m";    }                                            #
function green_printf  { printf "\033[32m$@\033[0m";    }                                            #
function yellow_printf { printf "\033[33m$@\033[0m";    }                                            #
function white_printf  { printf "\033[1;37m$@\033[0m";  }                                            #
# Debugging Outputs                                                                                  #
function white_brackets { local args="$@"; white_printf "["; printf "${args}"; white_printf "]";  }  #
function echoInfo  { local args="$@"; white_brackets $(green_printf "INFO") && echo " ${args}";   }  #
function echoWarn  { local args="$@"; white_brackets $(yellow_printf "WARN") && echo " ${args}";  }  #
function echoError { local args="$@"; white_brackets $(red_printf "ERROR") && echo " ${args}";    }  #
# Silences commands' STDOUT as well as STDERR.                                                       #
function silence { local args="$@"; ${args} &>/dev/null; }                                           #
# Check your privilege.                                                                              #
function checkPriv { if [[ "$EUID" != 0 ]]; then echoError "Please run me as root."; exit 1; fi;  }  #
# Returns 0 if script is sourced, returns 1 if script is run in a subshell.                          #
function checkSrc { (return 0 2>/dev/null); if [[ "$?" == 0 ]]; then return 0; else return 1; fi; }  #
# Prints directory the script is run from. Useful for local imports of BASH modules.                 #
function whereAmI { printf "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )";   }  #
######################################################################################################
#
## Bans list of IP addresses through ufw.
## Requires "ipban.txt" which contains one IPv4 or IPv6 address per line to ban.
## First argument given to this script can overwrite default name of "ipban.txt".

ipban_file="$1"

function bye {
  white_echo "OK"
}

function setIpbanFile {
  if [[ -z "${ipban_file}" ]]; then
    ipban_file="ipban.txt"
    echoInfo 'No filename set. Using default name "ipban.txt".'
  fi
}

function checkIP {
  ## Checks given IP format.
  ## Soft checking; no IP class matching.
  local ip="$1";
  if [[ $ip =~ ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]) ]]; then
    return 0;
  elif [[ $ip =~ (([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])) ]]; then
    return 0;
  else
    return 1;
  fi;
}

function installUfw {
  silence "ufw status"
	if [[ "$?" == 0 ]]; then
	  echoInfo "UFW installed."
	else
	  silence "apt-get update"
	  if [[ "$?" == 0 ]]; then
	    echoInfo "APT repositories updated."
	  else
	    echoWarn "Failed to update APT repositories."
	  fi
	  silence "apt-get install -y ufw"
	  if [[ "$?" == 0 ]]; then
	    echoInfo "UFW installed."
	  else
	    echoError "UFW installation failed. Exiting."
	    exit 1
	  fi
	fi
}

function denyFromIpFile {
  local -i line_number=0
  local errors_happened=false
  local fine_line
  while read -r line; do
    let "line_number++"
    fine_line="$(echo -e "${line}" | tr -d '[:space:]')"
    if [[ $(checkIP ${fine_line})$? == 0 ]]; then
      local progress="$(ufw insert 1 deny from ${fine_line})"
      if [[ "$?" == 0 ]]; then
        echoInfo ${progress}
      else
        echoWarn ${progress}
      fi
    elif [[ ${fine_line} == "" ]]; then
      echoWarn "Line ${line_number}: Empty line."
      continue
    else
      echoError "Line ${line_number}: Not a valid ip address entry.";
      errors_happened=true
      continue
    fi;
  done <${ipban_file};
  if [[ ${errors_happened} == true ]]; then
    echoWarn "Some IP entries were invalid. Check the ${ipban_file} file."
    return 1
  fi
  return 0;
}

checkPriv
installUfw
setIpbanFile
denyFromIpFile
bye
