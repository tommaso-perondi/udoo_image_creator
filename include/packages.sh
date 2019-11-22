#!/bin/bash

# Script fot update and install the packages and programs

# Included script

LOG_FILE_PATH="log/out.log"
DIR_PACKAGES=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR_PACKAGES/utils/color.sh"
################################################################################

ROOTFS_CMD_APT_INSTALL="export DEBIAN_FRONTEND=noninteractive; apt-get install -qy -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\""

function add_source_list() {
    echo_yellow "Adding source list"
    install -m 644 $DIR_PACKAGES/../configure/sources.list "mnt/etc/apt/sources.list"
}

function add_docker_repo(){
    echo_yellow "Adding new Docker repository"
    chroot mnt/ /bin/bash -c "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -"
    chroot mnt/ /bin/bash -c "echo 'deb [arch=armhf] https://download.docker.com/linux/ubuntu bionic stable' >> /etc/apt/sources.list"
    chroot mnt/ /bin/bash -c "apt-get update -y -qq"
}

function set_locales(){
    echo_yellow "Setup Locale"
    chroot mnt/ /bin/bash -c "locale-gen en_US.UTF-8 && dpkg-reconfigure --frontend noninteractive locales && update-locale LANG=en_US.UTF-8"
}

function install_packages() {
    # Update
    echo_yellow Installing update...
    chroot mnt/ /bin/bash -c "apt-get update -y"
    chroot mnt/ /bin/bash -c "apt-get upgrade -y"

    # # Packages list
    local base_packages="openssh-server ifupdown haveged policykit-1 curl iw module-init-tools ntp unzip usbutils wireless-tools wget wpasupplicant sysfsutils git i2c-tools python3-pip manpages wireless-regdb net-tools ca-certificates gnupg-agent linux-firmware vim"

    echo_yellow "Installing basic packages..."
    chroot mnt/ /bin/bash -c "${ROOTFS_CMD_APT_INSTALL} $base_packages"
    #Docker
    add_docker_repo
    echo_yellow "Installing docker packages"
    local docker_packages="docker-ce docker-ce-cli docker-compose"
    chroot mnt/ /bin/bash -c "${ROOTFS_CMD_APT_INSTALL} $docker_packages"
}
