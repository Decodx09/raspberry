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
  iso_checksum = "none" # Set to none to bypass download issues

  output_directory = "output"
  format           = "qcow2"
  disk_size        = "8G" # Increased disk size for the app
  
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
    ["-nographic"]
  ]

  ssh_username     = "ubuntu"
  ssh_password     = "ubuntu"
  ssh_timeout      = "60m"
  shutdown_command = "sudo shutdown -h now"
}

build {
  name    = "raspberry-pi-build"
  sources = ["source.qemu.ubuntu-arm"]

  # Upload all our custom files into the image
  provisioner "file" {
    source      = "automonQR.sh"
    destination = "/tmp/automonQR.sh"
  }
  provisioner "file" {
    source      = "update-app.sh"
    destination = "/tmp/update-app.sh"
  }
  provisioner "file" {
    source      = "automon-qr.service"
    destination = "/tmp/automon-qr.service"
  }
  provisioner "file" {
    source      = "myapp.service"
    destination = "/tmp/myapp.service"
  }

  # Run the final setup commands inside the image
  provisioner "shell" {
    inline = [
      "echo 'Setting up blue-green directories...'",
      "sudo mkdir -p /opt/app/blue /opt/app/green",
      "sudo ln -sfn /opt/app/blue /opt/app/current",
      "sudo chown -R appuser:appuser /opt/app",

      "echo 'Cloning placeholder application...'",
      "sudo git clone https://github.com/google-gemini/simple-python-app.git /opt/app/blue",

      "echo 'Installing scripts and services...'",
      "sudo mv /tmp/automonQR.sh /usr/local/bin/automonQR.sh",
      "sudo mv /tmp/update-app.sh /usr/local/bin/update-app.sh",
      "sudo mv /tmp/automon-qr.service /etc/systemd/system/automon-qr.service",
      "sudo mv /tmp/myapp.service /etc/systemd/system/myapp.service",

      "echo 'Setting permissions and enabling services...'",
      "sudo chmod +x /usr/local/bin/automonQR.sh",
      "sudo chmod +x /usr/local/bin/update-app.sh",
      "sudo systemctl enable automon-qr.service",
      "sudo systemctl enable myapp.service"
    ]
  }
}