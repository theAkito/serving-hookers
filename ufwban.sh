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
## Bans list of IP addresses through ufw.
## Requires "ipban.txt" which contains
## one IPv4/6 address per line to ban.
#
####  Boilerplate of the Boilerplate
# Coloured Outputs
# Echoes
function red_echo      { echo -e "\033[31m$@\033[0m";   }
function green_echo    { echo -e "\033[32m$@\033[0m";   }
function yellow_echo   { echo -e "\033[33m$@\033[0m";   }
function white_echo    { echo -e "\033[1;37m$@\033[0m"; }
# Printfs
function red_printf    { printf "\033[31m$@\033[0m";    }
function green_printf  { printf "\033[32m$@\033[0m";    }
function yellow_printf { printf "\033[33m$@\033[0m";    }
function white_printf  { printf "\033[1;37m$@\033[0m";  }

# Debugging Outputs
function white_brackets { local args="$@"; white_printf "["; printf "${args}"; white_printf "]";  }
function echoInfo  { local args="$@"; white_brackets $(green_printf "INFO") && echo " ${args}";   }
function echoWarn  { local args="$@"; white_brackets $(yellow_printf "WARN") && echo " ${args}";  }
function echoError { local args="$@"; white_brackets $(red_printf "ERROR") && echo " ${args}";    }

# Silences commands' STDOUT as well as STDERR.
function silence { local args="$@"; ${args} &>/dev/null; }
# Check your privilege.
function checkPriv { if [[ "$EUID" != 0 ]]; then echoError "Please run me as root."; exit 1; fi; }
# Finish line.
function bye { white_echo "OK"; }
####

function checkIP {
  ## Checks given IP format.
  ## Soft checking; no IP class matching.
  local ip="$1";
  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]]; then
    return 0;
  elif [[ $ip =~ ^[A-Fa-f0-9:]+ ]]; then
    return 0;
  else
    return 1;
  fi;
}

function installUfw {
	apt-get install -y ufw &>/dev/null && \
	return 0;
}

function enableUfw {
	ufw enable && \
	return 0;
}

function denyFromIpFile {
  local -i line_number=0
	local ipban_file="ipban.txt";
	local errors_happened=false
	local fine_line
	while read -r line; do
	  let "line_number++"
	  fine_line="$(echo -e "${line}" | tr -d '[:space:]')"
	  if [[ $(checkIP ${line})$? == 0 ]]; then
			ufw insert 1 deny from ${fine_line};
		elif [[ ${line} =~ [[:space:]] || ${line} == "" ]] ; then
		  echoWarn "Empty line."
		  continue
		else
			echoError "Line ${line_number}: Not a valid ip address entry.";
			errors_happened=true
			continue
		fi;
	done <${file};
	if [[ ${errors_happened} == true ]]; then
	  echoWarn "Some IP entries were invalid. Check the ${ipban_file} file."
	fi
	return 0;
}

checkPriv
installUfw
denyFromIpFile
bye
