#!/bin/bash
set -e

mkdir -p /output

# Create a blank 8GB file
truncate -s 8G /output/pi-image.img

# Create the partition table
sfdisk /output/pi-image.img << SFDISK_EOF
label: dos
,256M,c,*
,,L,
SFDISK_EOF

# Set up loopback device to map the partitions
LOOP_DEV=$(losetup -fP --show /output/pi-image.img)
BOOT_PART="${LOOP_DEV}p1"
ROOT_PART="${LOOP_DEV}p2"

# Format the partitions
mkfs.vfat -F32 "$BOOT_PART"
mkfs.ext4 "$ROOT_PART"

# Mount the root partition and copy the OS files
mkdir -p /mnt/root
mount "$ROOT_PART" /mnt/root
cp -a /rootfs/. /mnt/root/

# Mount the boot partition and copy the boot files
mkdir -p /mnt/root/boot/firmware
mount "$BOOT_PART" /mnt/root/boot/firmware
cp -a /bootfs/. /mnt/root/boot/firmware/

# Unmount everything
umount /mnt/root/boot/firmware
umount /mnt/root
losetup -d "$LOOP_DEV"

echo "Image creation complete!"