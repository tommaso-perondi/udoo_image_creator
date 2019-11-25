#!/bin/bash

# Script for the realization of the SDcard image and its configuration

# Included files
DIR_MKUDOOBUNTU=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR_MKUDOOBUNTU/include/imager.sh"
source "$DIR_MKUDOOBUNTU/include/utils/color.sh"
source "$DIR_MKUDOOBUNTU/include/set_user_and_root.sh"
source "$DIR_MKUDOOBUNTU/include/packages.sh"
source "$DIR_MKUDOOBUNTU/include/utils/utils.sh"
source "$DIR_MKUDOOBUNTU/include/utils/prints.sh"
source "$DIR_MKUDOOBUNTU/configure/udoo_neo.sh"
################################################################################

PRINTS_DEBUG=1
PRINTS_VERBOSE=1



# The first stage is the function that do the initial operation such as:
# creating partitions, upload the bootloader, ...
# Many of its operation are taken from ../include/imager.sh
function first_stage() {
    # Read arguments
    local OUTPUT=$1
    local LOOP=$2

    echo_i "Starting setup"

    # Create the empty image file - 4GB
    echo_i "Creating the image file $OUTPUT..."
    dd if=/dev/zero of=$OUTPUT bs=1 count=0 seek=3G 2>&1 > /dev/null
    echo_ok "Image created!"
    # Associate loop-device with .img file
    losetup $LOOP $OUTPUT || echo_red "Cannot set $LOOP"

    # Create the partitions - from include/imager.sh
    create_partitions $OUTPUT $LOOP
    # Copy the bootloader - from include/imager.sh
    write_bootloader $OUTPUT $LOOP

    # Mount udoobuntu18_04
    mkdir mnt 2> /dev/null
    mount "${LOOP}p1" mnt/
    # Copy the kernel - from include/imager.sh
    mkdir mnt/boot/
    write_kernel $OUTPUT $LOOP

    echo_ok "Setup complete!"

    # Debootstrap - first_stage
    echo_i "Starting debootstrap - first stage..."
    debootstrap --foreign --arch=armhf --verbose bionic mnt/ 2>&1 > out.log &
    local process_pid=$!
    progress_bar $process_pid "first stage"
    #tar -C mnt/ -xf ubuntu-base-18.04.3-base-armhf.tar
    echo_ok "debootstrap - first_stage: Done!"
}


# The second stage is the function that give the final configuration to
# the image file. An important operation is the debootstrap operaion executed
# in chroot.
function second_stage() {
    echo_i "Starting second-stage"

    # Copy the qemu file
    cp $DIR_MKUDOOBUNTU/source/qemu-arm/qemu-arm-static mnt/usr/bin

    # Change root and run the second stage
    chroot mnt/ /bin/bash -c "/debootstrap/debootstrap --second-stage" 2>&1 >> out.log &
    local process_pid=$!
    progress_bar $process_pid "second stage"

    echo_ok "Debootstrap second-stage completed!"
}

# This function configure the system: adding the default user, set the root
# password, install the packages...
function configuration() {
    echo_i "Starting configuration..."
    # Edit the hostname file
    chroot mnt/ /bin/bash -c "echo \"$HOSTNAME\" > /etc/hostname"

    # Install packages - from include/packages.sh
    add_source_list >> out.log 2>&1 &
    local process_pid=$!
    progress_bar $process_pid "setup source list"
    set_locales >> out.log 2>&1 &
    process_pid=$!
    progress_bar $process_pid "setup locale"
    install_packages >> out.log 2>&1 &
    process_pid=$!
    progress_bar $process_pid "install packages"
    
    echo_i "Adding resizefs"
    install -m 755 patches/firstrun  "mnt/etc/init.d"
    chroot "mnt/" /bin/bash -c "update-rc.d firstrun defaults > /dev/null 2>&1"
    cp patches/g_multi_setup.sh mnt/etc/rc.local
    chmod +x mnt/etc/rc.local
    echo_i "Configuring Network ..."
    cp patches/network_interface mnt/etc/network/interfaces

    # Setup the user and root - from include/set_user_and_root.sh
    set_root
    set_user

    echo_ok "Configuration complete!"
}


function final_operations() {
    # Read arguments
    local LOOP=$1

    umount -lf mnt
    rm -rf mnt
    losetup -d "$LOOP"
    sync
}

################################################################################
function main() {
    checkroot
    # Configuration
    local OUTPUT="udoobuntu-udoo_neo-18.04_$(date +%Y%m%d-%H%M).img"
    local LOOP=$(losetup -f)

    echo_i "Check dependencies..."
    check_dependencies "debootstrap"
    check_dependencies "qemu-arm-static"
    exit 2

    echo_i "Starting build..."
    first_stage $OUTPUT $LOOP
    second_stage $OUTPUT $LOOP
    configuration
    final_operations $LOOP

    echo_ok "Build complete!"
}

main $@
