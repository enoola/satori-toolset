#!/bin/bash

#satori_finish_install.sh

if [ !-d /root/.satori ]; then
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

cd $HOME

ret_install=$(/bin/bash ./install.sh)


log_info "service downloaded"

log_info "we will reaload daemon"
sudo systemctl daemon-reload
log_info "time to enable satori service"

sudo systemctl enable satori.service

log_info "time to start satori service"
sudo systemctl start satori.service

cd -
#log_info "cleaning time"
#rm -fv /etc/ini.d/run_mysetup_satori.sh
#systemctl disable runonce_my_satoriinstaller.sh
#rm -fv /etc/systemd/system/runonce_my_satoriinstaller.sh


