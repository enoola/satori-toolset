#!/bin/bash

#aim : install required packages post OS install, tested on :
#  - ubuntu server minimalist
# 06/11/2024, 00:40
#

#Install some packages
#Follow JMHP script to get docker

#set -e
set -euo pipefail
# e: exits on error
# u: exits on undefined variables
# o pipefail: exits if any command in a pipe fails

if [ -d /root/.satori ]; then
   echo "folder /root/.satori exists we should not run it again"
fi

##                           ##
#  ----    FUNCTIONS    ----- #
##                           ##

# message syslog format
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message"
}

log_info() {
    local info_message="$1"
    log_message "INFO" "$info_message"
    echo "INFO: $info_message"
}

# Error handling function
handle_error() {
    local error_message="$1"
    log_message "ERROR" "$error_message"
    echo "ERROR: $error_message"
    exit 1
}


#I have proxmox, which leverage this as agent
#1 we want client paclage to be installed.
INSTALL_QEMU_AGENT=1

SCRIPT_USAGE="$0"

####
#
# Ajout des sources pour les repo PC X64 :

#HOME="/root"

# Import varoan;es
FILEPATH_OS_RELEASE="/etc/os-release"
. "${FILEPATH_OS_RELEASE}"

OSNAME_HOST=$(echo "$NAME" | tr '[:upper:]' '[:lower:]')
OSTYPE_HOST=$(uname | tr '[:upper:]' '[:lower:]')

ARCH_HOST=$(dpkg --print-architecture)
FILEPATH_APT_DOCKER_SOURCES="/etc/apt/sources.list.d/docker.list"
FILEPATH_GPGPUBKEY_DOCKER_REPOS="/etc/apt/keyrings/docker.asc"
URL_DOCKER_FORUBUNTU="https://download.docker.com/${OSTYPE_HOST}/${OSNAME_HOST}"

WORKING_DIR=${HOME}/.satori

#. ./packages_post_install.sh
#echo $ar_packages_to_install
ar_packages_to_install="\
git \
cron \
net-tools \
screen \
nano \
rsync \
jq \
htop \
zip \
unzip \
curl \
inetutils-tools"

if [ "${INSTALL_QEMU_AGENT}" -eq 1 ]; then
   ar_packages_to_install+=' qemu-guest-agent'
fi

#we install the  minimum needed
sudo apt install --yes ${ar_packages_to_install}

#Thanks to JMHP
#qemu-guest-agente
log_info "Will proceed with docker."
#We should remove if it is installed : dpkg-query, dpkg -S `which docker`

#Satori requirements
#
# Ajout des clefs officielles GPG :
#
if [ -f "${FILEPATH_GPGPUBKEY_DOCKER_REPOS}" ]; then
   log_info "File with GPG Repos PubKey ${FILEPATH_GPGPUBKEY_DOCKER_REPOS} exists.."
else
   log_info "File with GPG Repos PubKey ${FILEPATH_GPGPUBKEY_DOCKER_REPOS} doesn't exist."
   sudo apt-get install ca-certificates curl
   sudo install -m 0755 -d /etc/apt/keyrings
   sudo curl -fsSL "${URL_DOCKER_FORUBUNTU}/gpg" -o "${FILEPATH_GPGPUBKEY_DOCKER_REPOS}"
   sudo chmod a+r "${FILEPATH_GPGPUBKEY_DOCKER_REPOS}"
fi

echo \
  "deb [arch=${ARCH_HOST} signed-by=${FILEPATH_GPGPUBKEY_DOCKER_REPOS}] \"${URL_DOCKER_FORUBUNTU}\" \
\"${VERSION_CODENAME}\" stable" | \
sudo tee "${FILEPATH_APT_DOCKER_SOURCES}" > /dev/null

sudo apt-get update
# Installation de docker :
log_info "Time to proceed with Docker installation😁"

## Installation de docker :
sudo apt-get install --yes docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Tester que Docker fonctionne :
sz_expected_output='Hello from Docker'
ret_dockerrun=$(sudo docker run hello-world | grep "$sz_expected_output")
if test -z "${ret_dockerrun}"; then
	exit 1
fi

log_info "Docker seems ok, let's proceed with the binaries"

## isntall python environment
sudo apt-get install --yes software-properties-common
sudo add-apt-repository --yes ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install --yes python3.10 python3.10-venv
python3.10 --version
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

##download satori
dir_archive="${HOME}/backups/satori-archive"
mkdir -p "${dir_archive}"
cd "${HOME}"
wget -P "${HOME}" https://satorinet.io/static/download/linux/satori.zip
unzip "${HOME}/satori.zip"
stringwith_date=$(date +"%Y%m%d")
#echo '--> '.$stringwith_date.zip
mv ${HOME}/satori.zip ${dir_archive}/satori.${stringwith_date}.zip
cd ${HOME}/.satori
#set -x

#log_info "Will proceed with install.sh from satori.zip:.satori"
##install satori service

##ret_install=$(/bin/bash ./install.sh)

log_info "we passed 'install.sh'"
#sudo groupadd docker
#sudo usermod -aG docker $USER
#log_info "newgrp..."
#not sure it make sens since i do all in root(yeah yeah..)
#newgrp docker
##log_info "will do first sed"
##sed -i "s/#User=.*/User=$USER/" "$(pwd)/satori.service"
##log_info "will do first sed"
##sed -i "s|man newWorkingDirectory=.*|WorkingDirectory=$(pwd)|" "$(pwd)/satori.service"
log_info "will download satori"
wget -O /etc/systemd/system/satori.service https://raw.githubusercontent.com/enoola/satori-toolset/refs/heads/main/satori.service.root_static

#below will need to be executed at first login from root
ret_install=$(/bin/bash ./install.sh)


log_info "service downloaded"

log_info "we will reaload daemon"
sudo systemctl daemon-reload
log_info "time to enable satori service"

sudo systemctl enable satori.service

log_info "time to start satori service"
sudo systemctl start satori.service

log_info "cleaning time"
rm -fv /etc/ini.d/run_mysetup_satori.sh
systemctl disable runonce_my_satoriinstaller.sh
rm -fv /etc/systemd/system/runonce_my_satoriinstaller.sh
