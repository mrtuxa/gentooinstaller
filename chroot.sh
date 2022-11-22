#!/usr/bin/env bash

hostname="gentoo"

function setupEnv() {
  source /etc/profile;
  export PS1="(chroot) ${PS1}";
}

function ConfiguringPortage() {
  emerge-webrsync;
  emerge --sync;
  emerge --ask app-portage/cpuid2cpuflags;
  echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags
}

function TimeZone() {
  echo "Europe/Berlin" > /etc/timezone;
  emerge --config timezone-data;
}

function locale() {
  echo "en_US ISO-8859-1" > /etc/locale.gen;
  echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen;
  echo "de_DE ISO-8859-1" >> /etc/locale.gen;
  echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen;
  locale-gen;
  eselect locale set 9;
  env-update;
  source /etc/profile;
  export PS1="(chroot) ${PS1}";
}

function kernel() {
  emerge -a sys-kernel/linux-firmware sys-kernel/gentoo-sources sys-apps/pciutils sys-kernel/gentoo-kernel-bin;
}

function hostname() {
  echo "# Set the hostname variable to set the selected host name" > /etc/conf.d/hostname;
  echo "hostname=$(hostname)";
}

function installDhcpcd() {
  emerge --ask net-misc/dhcpcd;
  rc-update add dhcpcd default;
}

function setRootPassword() {
  passwd;
}

function systemLogger() {
  emerge -a app-admin/sysklogd;
  rc-update add sysklogd default;
}

function timeSynchronization() {
  emerge --ask net-misc/chrony;
  rc-update add chronyd default;
}

function FileSystemTools() {
  emerge -a sys-fs/e2fsprogs 	sys-fs/dosfstools;
}

function bootloader() {
  echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf;
  emerge --ask sys-boot/grub;
  grub-install --target=x86_64-efi --efi-directory=/boot;
  grub-mkconfig -o /boot/grub/grub.cfg;
}