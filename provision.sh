#!/bin/bash

# create vagrant user
useradd vagrant

# set vagrant user's password
echo "vagrant:vagrant" | chpasswd

# create vagrant user's home directory and .ssh directory
mkdir -p /home/vagrant/.ssh

# chown home folder and .ssh folder to vagrant user
chown -R vagrant:vagrant /home/vagrant/

# change .ssh dir to 700 permissions
chmod 700 /home/vagrant/.ssh

# add vagrant's default insecure public key
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" >> /home/vagrant/.ssh/authorized_keys

# change permissions on authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys

# change ownership on authorized_keys
chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys

# install sudo
pacman -S sudo --noconfirm

# add vagrant user to sudoers list
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/vagrant
