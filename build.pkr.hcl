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
  iso_url              = "https://cdimage.ubuntu.com/ubuntu-server/jammy/daily-live/current/jammy-live-server-arm64.iso"
  iso_checksum         = "sha256:8842d38688463b369947701768832d2b52b5af471775837ba40866a2c207a48d"
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
