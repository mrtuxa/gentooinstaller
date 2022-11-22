#!/usr/bin/env bash



function env() {
    bootdisk="/dev/sda1";
    swapdisk="/dev/sda2";
    rootdisk="/dev/sda3";
    rootmountdir="/mnt/gentoo"
    bootmountdir="$rootmountdir/boot";
    server="https://ftp.fau.de";
    gentooserverdir="/gentoo/releases/amd64/autobuilds/current-stage3-amd64-desktop-openrc";
    stage3="stage3-amd64-desktop-openrc-20221120T170155Z.tar.xz";
}

function mountRootDisk() {
    # Mount Root Disk
    mkdir $rootmountdir;
    mkfs.ext4 $rootdisk;
    mount $rootdisk $rootmountdir;
}

function mountBootDisk() {
    # Mount Boot Disk
    mkdir $bootmountdir;
    mkfs.fat -F 32 $bootdisk;
    mount $bootdisk $bootmountdir;
}

function enableSwap() {
    # Create and enable swap
    mkswap $swapdisk;
    swapon $swapdisk;
}

function Stage3() {
  wget $server$gentooserverdir$stage3 -O $rootmountdir;
  tar xpvf $stage3 --xattrs-include='*.*' --numeric-owner --directory=$rootmountdir
}

function GentooEbuildRepo() {
  mkdir --parents $rootmountdir/etc/portage/repos.conf
  cp $rootmountdir/usr/share/portage/config/repos.conf $rootmountdir/etc/portage/repos.conf/gentoo.conf
}

function copyDNS() {
  copy --dereference /etc/resolv.conf $rootmountdir/etc
}

function mountNecessaryFilesystem() {
  mount --types proc /proc /mnt/gentoo/proc
  mount --rbind /sys /mnt/gentoo/sys
  mount --make-rslave /mnt/gentoo/sys
  mount --rbind /dev /mnt/gentoo/dev
  mount --make-rslave /mnt/gentoo/dev
  mount --bind /run /mnt/gentoo/run
  mount --make-slave /mnt/gentoo/run
}

function writeStartupScriptToRoot() {
  cp chroot.sh $rootmountdir/root
  cp bashrc $rootmountdir/root
  chroot /mnt/gentoo /bin/bash
}