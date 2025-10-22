# Stage 1: Prepare the root filesystem
FROM --platform=linux/arm64 ubuntu:22.04 AS rootfs_builder
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y systemd systemd-sysv git python3-pip adduser
RUN useradd --create-home --shell /bin/bash appuser

# Stage 2: Assemble the final image
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
# Install the necessary tools, INCLUDING sudo and ca-certificates
RUN apt-get update && apt-get install -y --no-install-recommends dosfstools e2fsprogs fdisk util-linux sudo git ca-certificates

# Create the output directory
RUN mkdir -p /output

# Get the Raspberry Pi bootloader files
RUN git clone --depth=1 https://github.com/raspberrypi/firmware.git /rpi-firmware

# Copy the prepared root filesystem from the first stage
COPY --from=rootfs_builder / /rootfs/

# Copy the assembly script
COPY scripts/create-image.sh /usr/local/bin/create-image.sh

# Run the script to create the final .img file
CMD ["/usr/local/bin/create-image.sh"]