#!/usr/bin/env bash

# Copyright (C) 2018 Harsh 'MSF Jarvis' Shandilya
# Copyright (C) 2018 Akhil Narang
# SPDX-License-Identifier: GPL-3.0-only

# Script to setup an AOSP Build environment on Ubuntu and Linux Mint
green="\033[92m"

sudo apt update && sudo apt upgrade -y

LATEST_MAKE_VERSION="4.3"
UBUNTU_16_PACKAGES="libesd0-dev"
UBUNTU_20_PACKAGES="libncurses5 curl python-is-python3"
DEBIAN_10_PACKAGES="libncurses5"
DEBIAN_11_PACKAGES="libncurses5"
PACKAGES=""

sudo apt install software-properties-common -y
sudo apt update

# Install lsb-core packages
sudo apt install lsb-core -y

LSB_RELEASE="$(lsb_release -d | cut -d ':' -f 2 | sed -e 's/^[[:space:]]*//')"

if [[ ${LSB_RELEASE} =~ "Mint 18" || ${LSB_RELEASE} =~ "Ubuntu 16" ]]; then
    PACKAGES="${UBUNTU_16_PACKAGES}"
elif [[ ${LSB_RELEASE} =~ "Ubuntu 20" || ${LSB_RELEASE} =~ "Ubuntu 21" || ${LSB_RELEASE} =~ "Ubuntu 22" || ${LSB_RELEASE} =~ 'Pop!_OS 2' ]]; then
    PACKAGES="${UBUNTU_20_PACKAGES}"
elif [[ ${LSB_RELEASE} =~ "Debian GNU/Linux 10" ]]; then
    PACKAGES="${DEBIAN_10_PACKAGES}"
elif [[ ${LSB_RELEASE} =~ "Debian GNU/Linux 11" ]]; then
    PACKAGES="${DEBIAN_11_PACKAGES}"
fi

sudo DEBIAN_FRONTEND=noninteractive \
    apt install \
    adb autoconf automake axel bc bison build-essential \
    ccache clang cmake curl expat fastboot flex g++ \
    g++-multilib gawk gcc gcc-multilib git git-lfs gnupg gperf \
    htop imagemagick lib32ncurses5-dev lib32z1-dev libtinfo5 libc6-dev libcap-dev \
    libexpat1-dev libgmp-dev '^liblz4-.*' '^liblzma.*' libmpc-dev libmpfr-dev libncurses5-dev \
    libsdl1.2-dev libssl-dev libtool libxml2 libxml2-utils '^lzma.*' lzop \
    maven ncftp ncurses-dev patch patchelf pkg-config pngcrush \
    pngquant python2.7 python-all-dev re2c schedtool squashfs-tools subversion \
    texinfo unzip w3m xsltproc zip zlib1g-dev lzip \
    libxml-simple-perl libswitch-perl apt-utils rsync \
    ${PACKAGES} -y

echo -e "Installing GitHub CLI"
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh

echo -e "Setting up udev rules for adb!"
sudo curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules -O -L https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules
sudo chmod 644 /etc/udev/rules.d/51-android.rules
sudo chown root /etc/udev/rules.d/51-android.rules
sudo systemctl restart udev

if [[ "$(command -v make)" ]]; then
    makeversion="$(make -v | head -1 | awk '{print $3}')"
    if [[ ${makeversion} != "${LATEST_MAKE_VERSION}" ]]; then
        echo "Installing make ${LATEST_MAKE_VERSION} instead of ${makeversion}"
        bash "$(dirname "$0")"/make.sh "${LATEST_MAKE_VERSION}"
    fi
fi

sudo apt update; sudo apt upgrade -y
sudo apt update -y && sudo apt upgrade -y && sudo apt install nano bc bison ca-certificates curl flex gcc git libc6-dev libssl-dev openssl python-is-python3 ssh wget zip zstd sudo make clang gcc-arm-linux-gnueabi software-properties-common build-essential libarchive-tools gcc-aarch64-linux-gnu -y && sudo apt install build-essential -y && sudo apt install libssl-dev libffi-dev libncurses5-dev zlib1g zlib1g-dev libreadline-dev libbz2-dev libsqlite3-dev make gcc -y && sudo apt install pigz -y && sudo apt install python2 -y && sudo apt install python3 -y
sudo apt-get install libc6 build-essential nghttp2 libnghttp2-dev libssl-dev zstd lld elfutils libarchive-tools  -y
sudo apt-get -y install -f cpio gcc llvm lld g++-multilib python2 clang git libxml2 python3-pip gcc llvm lld g++-multilib clang default-jre git automake lzop bison gperf build-essential zip curl zlib1g-dev g++-multilib libxml2-utils bzip2 libbz2-dev libbz2-1.0 libghc-bzlib-dev squashfs-tools pngcrush schedtool dpkg-dev python3 liblz4-tool make optipng bc libstdc++6 libncurses5 wget python3 python3-pip gcc clang libssl-dev rsync flex git-lfs libz3-dev libz3-4 axel tar bc binutils-dev bison build-essential ca-certificates ccache clang cmake curl file flex git libelf-dev libssl-dev lld make ninja-build python3-dev texinfo u-boot-tools xz-utils zlib1g-dev && python3 -m pip install networkx
echo "deb http://azure.archive.ubuntu.com/ubuntu noble main restricted universe" | sudo tee -a /etc/apt/sources.list.d/ubuntu-noble.list
echo "deb http://azure.archive.ubuntu.com/ubuntu noble-updates main restricted universe" | sudo tee -a /etc/apt/sources.list.d/ubuntu-noble-updates.list
sudo apt update; sudo apt-get install binutils -y
echo -e "${green}Dependencies succesfull installed\n"
