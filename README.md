# Collection of install/update/config bash scripts
##### Make sure you install these dependencies before executing any of the scripts.
```
sudo apt install -y wget git build-essential
```

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