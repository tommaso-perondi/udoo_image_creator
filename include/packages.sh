#!/bin/bash

# Script fot update and install the packages and programs

# Included script
DIR_PACKAGES=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR_PACKAGES/utils/color.sh"
################################################################################

function add_source_list() {
    echo_yellow "Adding source list"
    install -m 644 $DIR_PACKAGES/../configure/sources.list "mnt/etc/apt/sources.list"
}

function add_docker_repo(){
    chroot mnt/ /bin/bash -c "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -"
    chroot mnt/ /bin/bash -c "echo 'deb [arch=armhf] https://download.docker.com/linux/ubuntu bionic stable' >> /etc/apt/sources.list"
    chroot mnt/ /bin/bash -c "apt-get update -y"
}

function set_locales(){
    chroot mnt/ /bin/bash -c "locale-gen en_US.UTF-8 && dpkg-reconfigure locales && update-locale LANG=en_US.UTF-8"
}

function install_packages() {
    # Update
    echo_yellow Installing update...
    chroot mnt/ /bin/bash -c "apt-get update -y"
    chroot mnt/ /bin/bash -c "apt-get upgrade -y"

    # # Packages list
    local BASE_PACKAGES="openssh-server policykit-1 curl iw module-init-tools ntp unzip usbutils wireless-tools wget wpasupplicant sysfsutils git i2c-tools python3-pip manpages wireless-regdb net-tools ca-certificates gnupg-agent linux-firmware vim"

    chroot mnt/ /bin/bash -c "apt-get install $BASE_PACKAGES -y"
    #Docker
    add_docker_repo
    local DOCKER="docker-ce docker-ce-cli docker-compose"
    chroot mnt/ /bin/bash -c "apt-get install $DOCKER -y"
}
