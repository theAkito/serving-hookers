#!/bin/bash
# See LICENSE.
# Copyright (C) 2019 Akito

## Bans list of IP addresses through ufw.
## Requires "ipban.txt" which contains
## one IPv4/6 address per line to ban.

function checkPriv {
  if [[ "$EUID" != 0 ]]; then
    ## Check your privilege.
    echo "Please run me as root.";
    exit 1;
  fi;
}

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
	local file="ipban.txt";
	while read -r line; do
	  if [[ $(checkIP ${line})$? == 0 ]]; then
			ufw deny from ${line};
		else
			echo "Not a valid ipban.txt file. Exiting.";
			exit 1;
		fi;
	done <${file};
	return 0;
}

function bye { echo "Done!"; }

checkPriv
installUfw           && \
denyFromIpFile       && \
bye

