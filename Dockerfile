# Stage 1: Prepare the root filesystem
FROM --platform=linux/arm64 ubuntu:22.04 AS rootfs_builder
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y systemd systemd-sysv git python3-pip adduser
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
RUN apt-get update && apt-get install -y dosfstools e2fsprogs fdisk util-linux

COPY --from=rootfs_builder / /rootfs/
COPY --from=bootfs_builder /bootfs/ /bootfs/
COPY scripts/create-image.sh /usr/local/bin/create-image.sh
CMD ["/usr/local/bin/create-image.sh"]