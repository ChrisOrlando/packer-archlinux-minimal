#!/bin/bash

DISK="/dev/sda"
PARTITION="${DISK}1"


parted -s "$DISK" mklabel msdos

# create primary partition with optimal alignment
parted -s -a optimal "$DISK" mkpart primary 0% 100%

# make partition bootable
parted -s "$DISK" set 1 boot on

# format partition ext4
mkfs.ext4 -F "$PARTITION"

# mount partition
mount "$PARTITION" /mnt

# install arch
pacstrap /mnt base grub openssh

# generate fstab
genfstab -p /mnt >> /mnt/etc/fstab

# write MBR
arch-chroot /mnt grub-install --target=i386-pc --recheck /dev/sda

# set up grub config
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# set root password
echo "root:root" | arch-chroot /mnt chpasswd

# enabled ssh service
arch-chroot /mnt systemctl enable sshd.service

# unmount /mnt
umount -R /mnt
