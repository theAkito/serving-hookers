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
distribution_name="$1"
repository_channels="$2"
function hello {
  ## Checks if Docker works on this system already.
  ## Warns, if Docker already is installed.
  silence "docker version"
  if [[ $? == 0 ]]; then
    echoWarn "Docker already installed!"
    white_printf "Do you want to continue installing Docker, anyway? (YES or NO):  "
    while :; do
      read answer
      if [[ ${answer} == "YES" ]]; then
        return 0
      elif [[ ${answer} == "NO" ]]; then
        white_echo "OK"
        exit 0
      else
        echoWarn "Please enter YES to continue or NO to abort."
      fi
    done
  else
    return 0
  fi
}
function removePrevious {
  # Package "docker-engine" might be missing, resulting in unnecessary error.
  silence "apt-get remove -y docker-engine" || true
  silence "apt-get remove -y \
             docker \
             docker.io \
             containerd \
             runc"
  if [[ $? != 0 ]]; then
    echoError "Failed to remove previous Docker versions through APT. Exiting."
    exit 1
  else
    echoInfo "Successfully removed previous Docker versions through APT."
  fi
}
function addRepo {
  ## Takes the system's architecture as the first argument and
  ## uses it to select and add the correct Docker APT repository.
  ## Corrects possible issues with architecture and distribution
  ## names.
  local arch="$1"
  local distName
  if ! [[ -z "${distribution_name}" ]]; then
    distName="${distribution_name}"
  else
    distName="$(lsb_release -cs)"
  fi
  if [[ -z "${repository_channels}" ]]; then
    repository_channels="stable"
  fi
  case "${distName}" in
    bullseye)
      distName="buster";;
    sid)
      distName="buster";;
  esac
  silence "mkdir /etc/apt/sources.list.d/"
  echo "deb [arch=${arch}] https://download.docker.com/linux/debian ${distName} ${repository_channels}" > /etc/apt/sources.list.d/docker.list
  if [[ $? != 0 ]]; then
    echoError "Failed to add Docker APT repository. Exiting."
    exit 1
  else
    echoInfo "Successfully added Docker APT repository."
  fi
}
function chooseRepo {
  ## Detects system's CPU architecture and adds the Docker APT repository
  ## depending on the detected CPU architecture.
  arch="$(uname -m)"
  case "${arch}" in
    x86_64|amd64)
      addRepo amd64;;
    armhf)
      addRepo armhf;;
    arm64|aarch64)
      addRepo arm64;;
    *)
      echoError "The CPU architecture of this PC is not supported. Exiting."
      exit 1;;
  esac
}
function update {
  silence "apt-get update"
  if [[ $? != 0 ]]; then
    echoError "Failed to update APT index. Exiting."
    exit 1
  else
    echoInfo "Successfully updated APT index."
  fi
}
function getDeps {
  silence "apt-get install -y \
    lsb-release \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2"
  if [[ $? != 0 ]]; then
    echoError "Failed to get dependencies through APT. Exiting."
    exit 1
  else
    echoInfo "Successfully got dependencies through APT."
  fi
}
function getDockerPubKey {
  curl -fsSL https://download.docker.com/linux/debian/gpg | \
  silence "apt-key add -"
  if [[ $? != 0 ]]; then
    echoError "Failed to add APT key. Exiting."
    exit 1
  else
    echoInfo "Successfully added APT key."
  fi
}
function getDockerPackages {
  silence "apt-get -y install \
             docker-ce \
             docker-ce-cli \
             containerd.io"
  if [[ $? != 0 ]]; then
    echoError "Failed to get Docker through APT. Exiting."
    exit 1
  else
    echoInfo "Successfully got Docker through APT."
  fi
}
function bye {
  silence "docker version"
  if [[ $? == 0 ]]; then
    echoInfo "Successfully installed Docker."
    echo "------------------------------------------------"
    white_echo "Add your non-root user to the Docker group,"
    white_echo "if you would like to use Docker with this user"
    white_echo "like this:"
    yellow_echo 'usermod -aG docker $USER'
  else
    echoError "Docker installation failed."
    exit 1
  fi
}
# Checks if Docker works on this system already.
# Warns, if Docker already is installed.
hello
# Checks if user running this script is `root`.
checkPriv
# Removes previous Docker versions.
removePrevious
# Updating APT index.
update
# Getting dependencies.
getDeps
# Adding Docker GPG pubkey.
getDockerPubKey
# Choosing and adding correct Docker repository.
chooseRepo
# Updating APT index.
update
# Gets the actual Docker packages.
getDockerPackages
# Checks if Docker runs as it should.
bye