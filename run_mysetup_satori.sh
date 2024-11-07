#!/bin/bash
# This script downloads and executes the satori_allinone.sh script

#location : /etc/init.d/run_mysetup_satori.sh
wget -O ~/satori_allinone.sh https://raw.githubusercontent.com/enoola/satori-toolset/refs/heads/main/satori_allinone.sh
chmod +x ~/satori_allinone.sh
/root/satori_allinone.sh
