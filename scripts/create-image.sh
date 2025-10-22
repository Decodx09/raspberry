#!/bin/bash
set -e

# Create a blank 8GB file
truncate -s 8G /output/pi-image.img

# Create the partition table
sfdisk /output/pi-image.img << SFDISK_EOF
label: dos
,256M,c,*
,,L,
SFDISK_EOF

# Set up loopback device to map the partitions
LOOP_DEV=$(sudo losetup -fP --show /output/pi-image.img)
BOOT_PART="${LOOP_DEV}p1"
ROOT_PART="${LOOP_DEV}p2"

# Format the partitions
sudo mkfs.vfat -F32 "$BOOT_PART"
sudo mkfs.ext4 "$ROOT_PART"

# Mount the root partition and copy the OS files
sudo mkdir -p /mnt/root
sudo mount "$ROOT_PART" /mnt/root
sudo cp -a /rootfs/. /mnt/root/

# Mount the boot partition and copy the boot files
sudo mkdir -p /mnt/root/boot/firmware
sudo mount "$BOOT_PART" /mnt/root/boot/firmware
sudo cp -a /bootfs/. /mnt/root/boot/firmware/

# Unmount everything
sudo umount /mnt/root/boot/firmware
sudo umount /mnt/root
sudo losetup -d "$LOOP_DEV"

echo "Image creation complete!"
