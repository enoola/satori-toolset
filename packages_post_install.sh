## List Of Packages
#
# ./packages_post_install.sh


ar_packages_to_install="\
cron \
net-tools \
screen \
nano \
rsync \
net-tools \
jq \
htop \
zip \
unzip \
curl \
cron \
inetutils-tools"

if [ "${INSTALL_QEMU_AGENT}" -eq 1 ]; then
   ar_packages_to_install+=' qemu-guest-agent'
fi
