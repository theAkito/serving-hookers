[![Build Status](https://drone.akito.ooo:52222/api/badges/Akito/serving-hookers/status.svg)](https://drone.akito.ooo:52222/Akito/serving-hookers)
# Collection of install/update/config bash scripts
##### Make sure you install these dependencies before executing any of the scripts.
```
sudo apt install -y wget git build-essential
```

#### Go >=1.11.2 on Raspberry Pi armv6+
* `go1.13.1_arm_bootstrap.sh` installs Go v1.13.1 on any Raspberry Pi running Raspbian Stretch based systems using my pre-compiled Go toolchain.
* `go1.11.2_arm_bootstrap_CC.sh` cross-compiles the needed Go toolchains from scratch, if you don't want to use the pre-compiled one. The host machine executing the cross-compilation is assumed to be of the `amd64` architecture.

#### UFW Rules applier from file
If you are managing your server's firewall with UFW anyway you sometimes come across at the point noticing that the rules you make with plain iptables are ignored by the UFW layer on the top. This is not helpful when you need to apply a lot of rules at once, preferably from multiple files that you structure yourself, so the one `user.rules` file wouldn't be enough help. This way you also only need to get e.g. the IP addresses you want to block in a file, instead of making a rule on each line for each address, which is additionally more painful to execute due to the iptables style used in that file.
This script allows you to read 4 types of files:
1. A list of IP addresses, one per line.
You can deny and/or allow all traffic resulting from these source addresses like this:
```
bash ufwban.sh [ -i IP_WHITELIST ] [ -I IP_BLACKLIST ]
```
2. A list of Ports, one per line.
You can either deny or allow all traffic trying to pass through these Ports like this:
```
bash ufwban.sh [ -p PORT_WHITELIST ] [ -P PORT_BLACKLIST ]
```

You can apply all lists at once or only the ones you currently need.

#### Micro Text Editor
NOTE: Make sure your system has a working Go >=1.5 installation before executing the following script.
* `micro_install.sh` installs Micro on your system.

#### Gotify Server
NOTE: Make sure your system has working Go >=1.11.2 and NodeJS >=11.0 installations before executing the following scripts.
* `gotify-server_install.sh` installs a gotify-server from source, without using Docker.
* `gotify-server_update.sh` updates the previous gotify-server installation, by backing up the old one and replacing it with the `master` version.

#### Hugo Server
NOTE: Make sure your system has a working Go >=1.12.1 installation before executing the following script.
* `hugo_install.sh` installs Hugo on your system.

#### ZFSonLinux on Raspberry Pi armv6+
* `zfsonlinux-armv6_install+update.sh` installs or updates ZFSonLinux on any Raspberry Pi running Raspbian Stretch based systems. Source this script instead of running it in a subshell.