packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.7"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "device_name" {
  type    = string
  default = "default-pi"
}

variable "device_hmac" {
  type    = string
  default = "default-hmac"
}

source "qemu" "ubuntu-arm" {
  qemu_binary  = "qemu-system-aarch64"
  iso_url      = "https://releases.ubuntu.com/22.04.4/ubuntu-22.04.4-live-server-arm64.iso"
  iso_checksum = "none"

  output_directory = "output"
  format           = "qcow2"
  accelerator      = "none"
  machine_type     = "virt"
  disk_size        = "4G"
  http_directory   = "http"
  boot_wait        = "5s"

  boot_command = [
    "<wait><enter><wait><f6><esc><wait><enter>",
    " autoinstall",
    " ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<enter>"
  ]

  qemuargs = [
    ["-M", "virt,gic-version=3"],
    ["-cpu", "cortex-a72"],
    ["-smp", "2"],
    ["-m", "2048"],
    # This is the critical fix for running in a non-graphical environment
    ["-nographic"] 
  ]

  ssh_username     = "ubuntu"
  ssh_password     = "ubuntu"
  ssh_timeout      = "45m"
  shutdown_command = "sudo shutdown -h now"
}

build {
  name    = "raspberry-pi-build"
  sources = ["source.qemu.ubuntu-arm"]
}