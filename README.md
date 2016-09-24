Packer Arch Linux Minimal
=========================

This repository contains a packer configuration, install script, and provisioning script that together are capable of building a minimal Arch Linux vagrant box.

Features
--------

I had simplicity in mind when creating this box. It has the following features.
- 64-bit
- Up to date as of September 3rd, 2016
- All space on / partition
- No Swap
- Includes base and base-devel package groups
- OpenSSH installed and running
- VirtualBox Guest Additions installed

Build instructions
------------------
~~~
$ git clone git@github.com:ChrisOrlando/packer-archlinux-minimal.git
$ cd packer-archlinux-minimal
$ packer build archlinux.json
~~~

Resources used to create this
-----------------------------
- https://github.com/elasticdog/packer-arch
- https://gist.github.com/Phaeilo/541f0361678ee07bf594
- https://wiki.archlinux.org/index.php/beginners'_guide
