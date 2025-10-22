# Stage 1: Prepare the root filesystem
FROM --platform=linux/arm64 ubuntu:22.04 AS rootfs_builder
ENV DEBIAN_FRONTEND=noninteractive
# Install all base software
RUN apt-get update && apt-get install -y systemd systemd-sysv git python3-pip curl jq wget

# --- ADD YOUR APPLICATION AND SERVICES ---
# Copy all your custom scripts and services into the builder
COPY automonQR.sh /tmp/
COPY update-app.sh /tmp/
COPY automon-qr.service /tmp/
COPY myapp.service /tmp/

RUN \
    # Create the app user
    useradd --create-home --shell /bin/bash appuser && \
    \
    # Create the blue-green directory structure
    mkdir -p /opt/app/blue /opt/app/green && \
    ln -sfn /opt/app/blue /opt/app/current && \
    \
    # Clone a real, public placeholder application
    git clone https://github.com/hiteshkr/Hello-World-Flask.git /opt/app/blue && \
    chown -R appuser:appuser /opt/app && \
    \
    # Install the scripts to their final location
    mv /tmp/automonQR.sh /usr/local/bin/automonQR.sh && \
    mv /tmp/update-app.sh /usr/local/bin/update-app.sh && \
    chmod +x /usr/local/bin/automonQR.sh && \
    chmod +x /usr/local/bin/update-app.sh && \
    \
    # Install and enable the systemd services
    mv /tmp/automon-qr.service /etc/systemd/system/automon-qr.service && \
    mv /tmp/myapp.service /etc/systemd/system/myapp.service && \
    systemctl enable automon-qr.service && \
    systemctl enable myapp.service
# --- END OF APPLICATION SETUP ---


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