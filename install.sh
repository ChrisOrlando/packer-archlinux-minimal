#!/bin/bash
set -euo pipefail

# virtualbox (sata) exposes /dev/sda, qemu (virtio) exposes /dev/vda
DISK=$(lsblk -dnpo NAME,TYPE | awk '$2 == "disk" && $1 ~ /\/(sd|vd)a$/ {print $1; exit}')
PARTITION="${DISK}1"

# wait for the live ISO to finish initializing the pacman keyring
until systemctl is-active --quiet pacman-init.service; do sleep 1; done

# one bootable linux partition spanning the whole disk (MBR)
echo 'type=83, bootable' | sfdisk -q --label dos "$DISK"

# format partition ext4
mkfs.ext4 -F "$PARTITION"

# mount partition
mount "$PARTITION" /mnt

# skip docs, man pages and translations; the box has no man-db to read them
# anyway. applied to the live ISO for pacstrap and to the target for later
# installs and upgrades.
NOEXTRACT='NoExtract = usr/share/doc/* usr/share/man/* usr/share/info/* usr/share/gtk-doc/* usr/share/help/* usr/share/locale/* !usr/share/locale/locale.alias'
sed -i "/^\[options\]/a ${NOEXTRACT}" /etc/pacman.conf

# install arch (the base group no longer includes a kernel)
pacstrap -K /mnt base linux grub openssh
sed -i "/^\[options\]/a ${NOEXTRACT}" /mnt/etc/pacman.conf

# generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# write MBR
arch-chroot /mnt grub-install --target=i386-pc "$DISK"

# set up grub config
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# set root password
echo "root:vagrant" | arch-chroot /mnt chpasswd

# allow root login over ssh (needed until provisioning creates the vagrant user)
echo "PermitRootLogin yes" > /mnt/etc/ssh/sshd_config.d/10-root-login.conf

# configure DHCP on all ethernet interfaces with systemd-networkd
cat > /mnt/etc/systemd/network/20-ethernet.network <<'NETWORK'
[Match]
Name=en* eth*

[Network]
DHCP=yes
NETWORK

ln -sf /run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf

# enable services
arch-chroot /mnt systemctl enable sshd.service systemd-networkd.service systemd-resolved.service

# unmount /mnt
umount -R /mnt

# reboot
systemctl reboot
