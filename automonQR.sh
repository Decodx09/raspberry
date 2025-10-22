#!/bin/bash
set -euo pipefail
DEVICE_NAME="Datalogic ADC, Inc. GFS4500"
VENDOR_ID="05f9"
PRODUCT_ID="223f"
TARGET_LINK="/dev/input/qr"
logger -t "qr-symlink" "Starting QR symlink script..."
EVENT_PATH=$(grep -l "$DEVICE_NAME" /sys/class/input/event*/device/name 2>/dev/null | head -n 1)
if [[ -z "$EVENT_PATH" ]]; then
  for ev in /sys/class/input/event*; do
    ven=$(cat "$ev/device/id/vendor" 2>/dev/null || true)
    pro=$(cat "$ev/device/id/product" 2>/dev/null || true)
    if [[ "$ven" == "$VENDOR_ID" && "$pro" == "$PRODUCT_ID" ]]; then
      EVENT_PATH="$ev"
      break
    fi
  done
fi
if [[ -z "$EVENT_PATH" ]]; then
  logger -t "qr-symlink" "QR scanner not found."
  exit 1
fi
EVENT_DEV=$(basename "$EVENT_PATH")
EVENT_FILE="/dev/input/${EVENT_DEV}"
logger -t "qr-symlink" "Found QR scanner at $EVENT_FILE. Creating symlink at $TARGET_LINK."
ln -sf "$EVENT_FILE" "$TARGET_LINK"
