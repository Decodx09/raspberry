#!/bin/bash
set -e

truncate -s 8G /output/pi-image.img

sfdisk /output/pi-image.img << SFDISK_EOF
label: dos
,256M,c,*
,,L,
SFDISK_EOF

LOOP_DEV=$(sudo losetup -fP --show /output/pi-image.img)
BOOT_PART="${LOOP_DEV}p1"
ROOT_PART="${LOOP_DEV}p2"

sudo mkfs.vfat -F32 "$BOOT_PART"
sudo mkfs.ext4 "$ROOT_PART"

sudo mkdir -p /mnt/root
sudo mount "$ROOT_PART" /mnt/root
sudo cp -a /rootfs/. /mnt/root/

sudo mkdir -p /mnt/root/boot/firmware
sudo mount "$BOOT_PART" /mnt/root/boot/firmware
sudo cp -a /rpi-firmware/boot/. /mnt/root/boot/firmware/

sudo umount /mnt/root/boot/firmware
sudo umount /mnt/root
sudo losetup -d "$LOOP_DEV"

echo "Image creation complete!"