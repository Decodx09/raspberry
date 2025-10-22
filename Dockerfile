# Stage 1: Prepare the root filesystem
FROM --platform=linux/arm64 ubuntu:22.04 AS rootfs_builder
ENV DEBIAN_FRONTEND=noninteractive
# Install all base software
RUN apt-get update && apt-get install -y systemd systemd-sysv git python3-pip curl jq wget software-properties-common adduser
# Create appuser (this would be in your autoinstall config)
RUN useradd --create-home --shell /bin/bash appuser

# Stage 2: Prepare the boot filesystem
FROM debian:stable-slim AS bootfs_builder
RUN apt-get update && apt-get install -y git && \
    git clone --depth=1 https://github.com/raspberrypi/firmware.git /rpi-firmware && \
    mkdir /bootfs && \
    cp -r /rpi-firmware/boot/* /bootfs/

# Stage 3: Assemble the final image
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
# Install disk tools
RUN apt-get update && apt-get install -y dosfstools e2fsprogs fdisk util-linux

# Copy the prepared filesystems from previous stages
COPY --from=rootfs_builder / /rootfs/
COPY --from=bootfs_builder /bootfs/ /bootfs/

# Copy the assembly script
COPY scripts/create-image.sh /usr/local/bin/create-image.sh

# Run the script to create the final .img file
CMD ["/usr/local/bin/create-image.sh"]