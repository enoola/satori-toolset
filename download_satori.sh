
#!/bin/bash

dir_archive="${HOME}/backups/satori-archive"
mkdir -p "${dir_archive}"
cd "${HOME}"
wget -P "${HOME}" https://satorinet.io/static/download/linux/satori.zip
unzip "${HOME}/satori.zip"
stringwith_date=$(date +"%Y%m%d")
echo '--> '.$stringwith_date.zip
mv ${HOME}/satori.zip ${dir_archive}/satori.${stringwith_date}.zip
cd ${HOME}/.satori

