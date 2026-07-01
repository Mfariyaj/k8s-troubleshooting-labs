#!/bin/bash
#
# cleanup.sh — Clean up Lab 15: Filesystem Journal Corruption
#

LOOP_FILE="/tmp/lab15_broken_fs.img"
MOUNT_POINT="/tmp/lab15_mount"

echo "============================================"
echo " Cleaning up Lab 15: Filesystem Journal Corruption"
echo "============================================"
echo ""

# Kill any processes using the mount
echo "[1/4] Stopping processes using ${MOUNT_POINT}..."
sudo fuser -k "$MOUNT_POINT" 2>/dev/null || true
sleep 1

# Unmount
echo "[2/4] Unmounting filesystem..."
if mount | grep -q "$MOUNT_POINT"; then
    sudo umount -l "$MOUNT_POINT" 2>/dev/null || true
    sudo umount -f "$MOUNT_POINT" 2>/dev/null || true
fi

# Detach loop device
echo "[3/4] Detaching loop devices..."
for loop in $(losetup -j "$LOOP_FILE" 2>/dev/null | cut -d: -f1); do
    sudo losetup -d "$loop" 2>/dev/null || true
done

# Also clean any lab15-related loop devices
for loop in $(losetup -a 2>/dev/null | grep "lab15" | cut -d: -f1); do
    sudo losetup -d "$loop" 2>/dev/null || true
done

# Remove files
echo "[4/4] Removing temporary files..."
rm -f "$LOOP_FILE" 2>/dev/null || true
rmdir "$MOUNT_POINT" 2>/dev/null || true

echo ""
echo "[✓] Lab 15 cleaned up successfully."
