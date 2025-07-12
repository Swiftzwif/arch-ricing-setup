#!/bin/bash
# format-usb.sh
# ------------------------------------------
# Safely format a USB drive as exFAT.
#
# Usage:
#   sudo ./format-usb.sh
#
# Steps:
#   1. Lists all removable drives.
#   2. Prompts you to select a device (e.g., sdb).
#   3. Asks for confirmation before formatting.
#   4. Formats the device as exFAT and mounts it at /mnt/swiftusb.
#
# WARNING: This will erase all data on the selected device!
#
# Example:
#   sudo ./format-usb.sh
# ------------------------------------------
set -e

# List removable drives
echo "Available removable drives:"
lsblk -o NAME,SIZE,MODEL,TRAN | grep -E 'usb|removable' || true

echo "Enter the device name to format (e.g., sdb):"
read DEV

if [[ -z "$DEV" ]]; then
  echo "No device entered. Exiting."
  exit 1
fi

DEV_PATH="/dev/$DEV"

# Confirm
echo "WARNING: This will erase all data on $DEV_PATH. Continue? (yes/no)"
read CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Aborted."
  exit 1
fi

# Unmount all partitions
sudo umount ${DEV_PATH}?* || true

# Wipe partition table
sudo wipefs -a $DEV_PATH

# Create new partition table and partition
sudo parted -s $DEV_PATH mklabel gpt
sudo parted -s $DEV_PATH mkpart primary 0% 100%

# Format as exFAT
sudo mkfs.exfat -n SWIFTUSB ${DEV_PATH}1

# Mount
MOUNT_POINT="/mnt/swiftusb"
sudo mkdir -p $MOUNT_POINT
sudo mount ${DEV_PATH}1 $MOUNT_POINT

echo "USB drive formatted as exFAT and mounted at $MOUNT_POINT." 