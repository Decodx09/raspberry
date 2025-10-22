#!/bin/bash
set -e # Exit immediately if a command fails

echo "--- Starting Application Update ---"

# Determine which directory is inactive
if [ "$(readlink -f /opt/app/current)" == "/opt/app/blue" ]; then
    INACTIVE_DIR="/opt/app/green"
else
    INACTIVE_DIR="/opt/app/blue"
fi

echo "Switching live symlink to the new version."
# Atomically switch the symlink
ln -sfn "$INACTIVE_DIR" /opt/app/current

echo "Restarting application service..."
# Note: This assumes a 'myapp.service' exists, which we'd also add via a provisioner
systemctl restart myapp.service

echo "Update complete. App is now running from $INACTIVE_DIR"
