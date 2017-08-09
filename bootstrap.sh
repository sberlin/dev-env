#!/bin/bash

# Install applications
apt-get update
apt-get install --assume-yes \
    make \
    zip \
    build-essential \
    linux-headers-`uname -r` \
    virtualbox-guest-dkms

# Configure applications
update-alternatives --set editor /usr/bin/vim.basic

if [ -n "$LOCALE" ]
then
    locale-gen
    localectl set-locale LANG="$LOCALE"
fi

if [ -n "$KEYMAP" ]
then
    localectl set-keymap "$KEYMAP"
    loadkeys "$KEYMAP"
fi

if [ -n "$TIMEZONE" ]
then
    timedatectl set-timezone "$TIMEZONE"
fi

# Install Desktop
if [ "$GUI" == "true" ]
then
    apt-get install --assume-yes \
        ubuntu-desktop \
        virtualbox-guest-x11 \
        unity-tweak-tool
fi
