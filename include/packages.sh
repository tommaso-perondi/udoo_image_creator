#!/bin/bash

# Script fot update and install the packages and programs

# Included script

LOG_FILE_PATH="log/out.log"
DIR_PACKAGES=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR_PACKAGES/utils/prints.sh"
################################################################################
ROOTFS_CMD_APT_INSTALL="apt-get install -qy -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\""
EXPORTS="export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C
export LANGUAGE=C
export LANG=C
export DEBIAN_PRIORITY=critical
export DEBCONF_NONINTERACTIVE_SEEN=true"

function add_source_list() {
    echo_i "Adding source list"
    install -m 644 $DIR_PACKAGES/../configure/sources.list "mnt/etc/apt/sources.list"
}


function set_locales(){
    echo_i "Setup Locale"
    chroot mnt/ /bin/bash <<EOF
locale-gen en_US.UTF-8
dpkg-reconfigure --frontend noninteractive locales
update-locale LANG=en_US.UTF-8
EOF
}

function install_packages() {
    # Update
    echo_i "Installing update..."
    chroot mnt/ /bin/bash -c "apt-get update -y"
    chroot mnt/ /bin/bash -c "apt-get upgrade -y"

    # # Packages list
    local base_packages="openssh-server ifupdown haveged policykit-1 curl iw module-init-tools ntp unzip usbutils wireless-tools wget wpasupplicant sysfsutils wireless-regdb net-tools ca-certificates gnupg-agent linux-firmware vim parted"

    echo_i "Installing basic packages..."
    chroot mnt/ /bin/bash <<EOF
${EXPORTS}
${ROOTFS_CMD_APT_INSTALL} $base_packages
    apt-get purge --auto-remove snap linux-firmware -y
    apt-get autoclean
    apt-get autoremove
    apt clean -y
    rm /var/lib/apt/lists/* -r
	
EOF
}
function install_flasher() {
    cp sources/script/seco-mmcflash.sh mnt/root/
    chmod +x mnt/root/seco-mmcflash.sh
    cp sources/script/seco-mmcflash.service mnt/lib/systemd/system/
    chroot mnt/ /bin/bash "systemctl enable seco-mmcflash.service"
}
