#!/bin/bash
# See LICENSE.
# Copyright (C) 2019 Akito <the@akito.ooo>

###   Boilerplate
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
function checkPriv {
  if [[ "$EUID" != 0 ]]; then
    ## Check your privilege.
    echoError "Please run me as root.";
    exit 1;
  fi;
}
###
function addRepo {
  ## Takes the system's architecture as the first argument and
  ## uses it to select and add the correct Docker APT repository.
  local arch="$1"
  add-apt-repository \
     "deb [arch=${arch}] https://download.docker.com/linux/debian \
     $(lsb_release -cs) \
     stable"
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
  if [[ $(uname -m) == x86_64 || $(uname -m) == amd64 ]]; then
    addRepo amd64
  elif [[ $(uname -m) == armhf ]]; then
    addRepo armhf
  elif [[ $(uname -m) == arm64 ]]; then
    addRepo arm64
  else
    echoError "The CPU architecture of this PC is not supported. Exiting."
  fi
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
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common"
  if [[ $? != 0 ]]; then
    echoError "Failed to get dependencies through APT. Exiting."
    exit 1
  else
    echoInfo "Successfully got dependencies through APT."
  fi
}
function getDockerPubKey {
  curl -fsSL https://download.docker.com/linux/debian/gpg | silence "apt-key add -"
  if [[ $? != 0 ]]; then
    echoError "Failed to add APT key. Exiting."
    exit 1
  else
    echoInfo "Successfully added APT key."
  fi
}
function getDockerPackages {
  silence "apt-get -y install docker-ce docker-ce-cli containerd.io"
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
    echo "--------------------------------------------------------"
    white_echo "Add your non-root user to the Docker group,"
    white_echo "if you would like to use Docker with this user"
    white_echo "like this:"
    yellow_echo 'usermod -aG docker $USER'
  else
    echoError "Docker installation failed."
    exit 1
  fi
}
# Checks if user running this script is `root`.
checkPriv
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
# Checks.
bye