Packer Arch Linux Minimal
=========================

This repository contains a packer configuration, install script, and provisioning script that together are capable of building a minimal Arch Linux vagrant box.

Features
--------

I had simplicity in mind when creating this box. It has the following features.
- Always up to date
- All space on / partition
- No Swap
- Only the base package group, a kernel, GRUB, OpenSSH and sudo; install base-devel yourself if you need it
- No docs, man pages or translations (configured via `NoExtract` in `/etc/pacman.conf`)
- OpenSSH installed and running
- VirtualBox Guest Additions (virtualbox box) or QEMU guest agent (libvirt box) installed

Requirements
------------
- [Packer](https://developer.hashicorp.com/packer) 1.7+ (plugins are installed automatically by `packer init`)
- One of:
  - [VirtualBox](https://www.virtualbox.org/) on an x86_64 host, for a `virtualbox` box (VirtualBox on Apple Silicon cannot run x86_64 guests)
  - [QEMU](https://www.qemu.org/), for a `libvirt` box

Build instructions
------------------
~~~
$ git clone git@github.com:ChrisOrlando/packer-archlinux-minimal.git
$ cd packer-archlinux-minimal
$ ./build.sh -only=virtualbox-iso.archlinux   # or -only=qemu.archlinux
$ vagrant box add --name archlinux-minimal archlinux-virtualbox.box
~~~

Running `./build.sh` with no arguments builds both boxes. Any extra arguments are passed to `packer build`.

On a host without KVM (such as an Apple Silicon Mac) the QEMU build has to fully emulate x86_64. Tell it to, and give the live ISO more time to boot. This takes around 10 minutes:
~~~
$ brew install hashicorp/tap/packer qemu
$ ./build.sh -only=qemu.archlinux -var qemu_accelerator=tcg -var shell_wait=240s
~~~

The latest ISO is fetched from `https://geo.mirror.pkgbuild.com/iso/latest` and verified against its `sha256sums.txt`. Use a different mirror with `./build.sh -var mirror_url=https://example.com/archlinux/iso/latest`.

Resources used to create this
-----------------------------
- https://github.com/elasticdog/packer-arch
- https://gist.github.com/Phaeilo/541f0361678ee07bf594
- https://wiki.archlinux.org/title/Installation_guide
