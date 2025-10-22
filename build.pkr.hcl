packer {
  required_plugins {
    arm = {
      version = ">= 1.1.2" // Updated version
      source  = "github.com/solo-io/packer-builder-arm" // The new, correct owner and path
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

source "arm" "ubuntu" {
  iso_url         = "https://cdimage.ubuntu.com/releases/22.04/release/ubuntu-22.04.4-preinstalled-server-arm64+raspi.img.xz"
  iso_checksum    = "sha256:56221c720510526e0e2270387588b56064f27f0d1a491f24d9b326372d689b91"
  output_filename = "output/generic-pi-image.img.xz"
}

build {
  name    = "raspberry-pi-build"
  sources = ["source.arm.ubuntu"]

  provisioner "file" {
    source      = "update-app.sh"
    destination = "/tmp/update-app.sh"
  }

  provisioner "shell" {
    inline = [
      "echo 'Waiting for cloud-init to finish...'",
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo '...'; sleep 1; done",
      "echo 'Updating packages...'",
      "sudo apt-get update -y && sudo apt-get upgrade -y",
      "echo 'Installing Python and Git...'",
      "sudo apt-get install -y python3-pip git",
      
      "echo 'Setting up blue-green directories...'",
      "sudo mkdir -p /opt/app/blue /opt/app/green",
      "sudo ln -sfn /opt/app/blue /opt/app/current",
      
      "echo 'Installing update script...'",
      "sudo mv /tmp/update-app.sh /usr/local/bin/update-app.sh",
      "sudo chmod +x /usr/local/bin/update-app.sh",

      "echo 'Provisioning for device: ${var.device_name}'"
    ]
  }
}
