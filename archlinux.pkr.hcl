packer {
  required_plugins {
    virtualbox = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/virtualbox"
    }
    qemu = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
    vagrant = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

variable "mirror_url" {
  type    = string
  default = "https://geo.mirror.pkgbuild.com/iso/latest"
}

# How long to wait after the ISO boot menu for the live environment's root shell.
variable "shell_wait" {
  type    = string
  default = "60s"
}

locals {
  boot_command = [
    "<enter><wait${var.shell_wait}>",
    "curl -sf http://{{ .HTTPIP }}:{{ .HTTPPort }}/install.sh | bash<enter>"
  ]
}

source "virtualbox-iso" "archlinux" {
  iso_url      = "${var.mirror_url}/archlinux-x86_64.iso"
  iso_checksum = "file:${var.mirror_url}/sha256sums.txt"

  guest_os_type        = "ArchLinux_64"
  guest_additions_mode = "disable"
  firmware             = "bios"
  hard_drive_interface = "sata"
  # pass guest TRIM through so freed blocks shrink the disk image
  hard_drive_discard       = true
  hard_drive_nonrotational = true
  disk_size                = 20480
  cpus                     = 2
  memory                   = 2048
  headless                 = true

  http_directory = "."
  boot_wait      = "5s"
  boot_command   = local.boot_command

  ssh_username     = "root"
  ssh_password     = "vagrant"
  ssh_timeout      = "30m"
  shutdown_command = "systemctl poweroff"
}

# Builds a libvirt box. Uses KVM where available; set -var qemu_accelerator=tcg
# to build under full emulation (e.g. on an Apple Silicon Mac).
variable "qemu_accelerator" {
  type    = string
  default = "kvm"
}

source "qemu" "archlinux" {
  iso_url      = "${var.mirror_url}/archlinux-x86_64.iso"
  iso_checksum = "file:${var.mirror_url}/sha256sums.txt"

  qemu_binary    = "qemu-system-x86_64"
  machine_type   = "q35"
  accelerator    = var.qemu_accelerator
  disk_interface = "virtio"
  # pass guest TRIM through so freed blocks are dropped when packer compacts the image
  disk_discard       = "unmap"
  disk_detect_zeroes = "unmap"
  net_device         = "virtio-net"
  format             = "qcow2"
  disk_size          = "20G"
  cpus               = 2
  memory             = 2048
  headless           = true

  http_directory = "."
  boot_wait      = "5s"
  boot_command   = local.boot_command

  ssh_username     = "root"
  ssh_password     = "vagrant"
  ssh_timeout      = "60m"
  shutdown_command = "systemctl poweroff"
}

build {
  sources = ["source.virtualbox-iso.archlinux", "source.qemu.archlinux"]

  provisioner "shell" {
    script = "provision.sh"
  }

  post-processor "vagrant" {
    output       = "archlinux-{{ .Provider }}.box"
    architecture = "amd64"
  }
}
