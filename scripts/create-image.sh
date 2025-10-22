#!/bin/bash
set -e

# Create the output directory if it doesn't exist
mkdir -p /output

# Create a blank 8GB file
truncate -s 8G /output/pi-image.img

# Create the partition table (boot and root)
sfdisk /output/pi-image.img << SFDISK_EOF
label: dos
,256M,c,*
,,L,
SFDISK_EOF

# Set up a loopback device to access the partitions
LOOP_DEV=$(sudo losetup -fP --show /output/pi-image.img)
BOOT_PART="${LOOP_DEV}p1"
ROOT_PART="${LOOP_DEV}p2"

# Format the newly created partitions
sudo mkfs.vfat -F32 "$BOOT_PART"
sudo mkfs.ext4 "$ROOT_PART"

# Mount the root partition and copy the main OS files into it
sudo mkdir -p /mnt/root
sudo mount "$ROOT_PART" /mnt/root
sudo cp -a /rootfs/. /mnt/root/

# Mount the boot partition and copy the Raspberry Pi firmware files into it
sudo mkdir -p /mnt/root/boot/firmware
sudo mount "$BOOT_PART" /mnt/root/boot/firmware
sudo cp -a /bootfs/. /mnt/root/boot/firmware/

# Unmount everything cleanly
sudo umount /mnt/root/boot/firmware
sudo umount /mnt/root
sudo losetup -d "$LOOP_DEV"

echo "Image creation complete!"