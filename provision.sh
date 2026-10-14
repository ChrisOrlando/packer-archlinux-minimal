#!/bin/bash
set -euo pipefail

# create vagrant user with a home directory
useradd -m vagrant

# set vagrant user's password
echo "vagrant:vagrant" | chpasswd

# add vagrant's default insecure public key
install -d -m 700 -o vagrant -g vagrant /home/vagrant/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys

# install sudo and base-devel
pacman -Syu --noconfirm --needed sudo base-devel

# add vagrant user to sudoers list
echo "vagrant ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vagrant
chmod 440 /etc/sudoers.d/vagrant

# install guest tools for the hypervisor packer is building with
case "${PACKER_BUILDER_TYPE:-}" in
  virtualbox-iso)
    # headless guest additions; vboxservice loads the vboxguest/vboxsf modules
    pacman -S --noconfirm --needed virtualbox-guest-utils-nox
    systemctl enable vboxservice.service
    ;;
  qemu)
    pacman -S --noconfirm --needed qemu-guest-agent
    ;;
esac

# disable root ssh login now that the vagrant user exists
rm -f /etc/ssh/sshd_config.d/10-root-login.conf

# clean package cache to shrink the box
rm -f /var/cache/pacman/pkg/*
