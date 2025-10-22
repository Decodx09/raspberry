packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.7"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "ubuntu-arm" {
  qemu_binary  = "qemu-system-aarch64"
  iso_url      = "https://releases.ubuntu.com/22.04.4/ubuntu-22.04.4-live-server-arm64.iso"
  iso_checksum = "none"

  output_directory = "output"
  format           = "qcow2"
  disk_size        = "8G"
  http_directory   = "http"
  boot_wait        = "5s"

  boot_command = [
    "<wait><enter><wait><f6><esc><wait><enter>",
    " autoinstall",
    " ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<enter>"
  ]

  ssh_username     = "ubuntu"
  ssh_password     = "ubuntu"
  ssh_timeout      = "60m"
  shutdown_command = "sudo shutdown -h now"
}

build {
  name    = "raspberry-pi-build"
  sources = ["source.qemu.ubuntu-arm"]

  provisioner "shell-local" {
    inline = ["echo 'Build finished, check the output directory for your image.'"]
  }
}