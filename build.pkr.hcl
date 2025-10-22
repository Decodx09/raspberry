packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.7"
      source = "github.com/hashicorp/qemu"
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
  iso_url = "https://releases.ubuntu.com/22.04.4/ubuntu-22.04.4-live-server-arm64.iso"
  iso_checksum = "sha256:e39383626ad5eda35728a417325b1612a674470f3f381f1f2a13063f1266e7b1"
  output_directory     = "output"
  format               = "qcow2"
  accelerator          = "none"
  machine_type         = "virt"
  cpu_model            = "cortex-a72"
  disk_size            = "4G"
  http_directory       = "http"
  boot_wait            = "5s"
  boot_command = [
    "<wait><enter><wait><f6><esc><wait><enter>",
    " autoinstall",
    " ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<enter>"
  ]
  ssh_username         = "ubuntu"
  ssh_password         = "ubuntu"
  ssh_timeout          = "30m"
  shutdown_command     = "sudo shutdown -h now"
}

build {
  name    = "raspberry-pi-build"
  sources = ["source.qemu.ubuntu-arm"]
  
  # Provisioners like file upload and shell scripts would run here,
  # after the OS has been installed.
}
