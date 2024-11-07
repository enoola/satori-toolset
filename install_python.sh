#!/bin/bash


set -x
# Will install specific version of python

#sudo apt-get update && sudo apt-get upgrade

sudo apt-get install software-properties-common
#arch spe ?
sudo add-apt-repository --yes ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install --yes python3.10 python3.10-venv
python3.10 --version
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
sed -i "s/#User=.*/User=$USER/" "$(pwd)/satori.service"
sed -i "s|WorkingDirectory=.*|WorkingDirectory=$(pwd)|" "$(pwd)/satori.service"
sudo cp satori.service /etc/systemd/system/satori.service
sudo systemctl daemon-reload
sudo systemctl enable satori.service
sudo systemctl start satori.service

set +x
