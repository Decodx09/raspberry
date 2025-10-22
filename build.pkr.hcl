packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.7"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "ubuntu-arm" {
  iso_url          = "https://releases.ubuntu.com/22.04.4/ubuntu-22.04.4-live-server-arm64.iso"
  iso_checksum     = "none"
  output_directory = "output"
  format           = "qcow2"
  accelerator      = "none"
  machine_type     = "virt"
  cpu_model        = "cortex-a72"
  disk_size        = "4G"
  ssh_username     = "ubuntu"
  ssh_password     = "ubuntu"
  ssh_timeout      = "30m"
  shutdown_command = "sudo shutdown -h now"
  // NOTE: We have removed the complex boot_command and http_directory for this test
}

build {
  name    = "raspberry-pi-build"
  sources = ["source.qemu.ubuntu-arm"]
}