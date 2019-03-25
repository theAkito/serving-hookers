# Collection of install/update/config bash scripts
#### Go v1.11.2 on Raspberry Pi armv6+
* `go1.11.2_arm_bootstrap.sh` installs Go v1.11.2 on any Raspberry Pi running Raspbian Stretch based systems using my pre-compiled Go toolchain.
* `go1.11.2_arm_bootstrap_CC.sh` cross-compiles the needed Go toolchains from scratch, if you don't want to use the pre-compiled one. The host machine executing the cross-compilation is assumed to be of the `amd64` architecture.

#### Gotify Server
NOTE: Make sure your system has working Go >1.11.2 and NodeJS >11.0 installations before executing the following scripts.
* `gotify-server_install.sh` installs a gotify-server from source, without using Docker.
* `gotify-server_update.sh` updates the previous gotify-server installation, by backing up the old one and getting the `master` version.

#### ZFSonLinux on Raspberry Pi armv6+
* `zfsonlinux-armv6_install+update.sh` installs or updates ZFSonLinux on any Raspberry Pi running Raspbian Stretch based systems.