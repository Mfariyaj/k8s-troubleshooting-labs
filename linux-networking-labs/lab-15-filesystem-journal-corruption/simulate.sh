#!/bin/bash
#
# simulate.sh — Simulates ext4 journal corruption causing read-only remount
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOOP_FILE="/tmp/lab15_broken_fs.img"
MOUNT_POINT="/tmp/lab15_mount"
LOOP_SIZE="256M"

echo "============================================"
echo " Lab 15: Filesystem Journal Corruption"
echo "============================================"
echo ""
echo "This simulation:"
echo "  1. Creates a loopback ext4 filesystem"
echo "  2. Writes some data to it"
echo "  3. Corrupts the journal area"
echo "  4. Triggers ext4 error detection → read-only remount"
echo ""
echo "This is safe — it only affects a temporary loopback file."
echo ""
read -p "Continue? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
    echo "Aborted."
    exit 0
fi

# Step 1: Create loopback filesystem
echo "[1/6] Creating ${LOOP_SIZE} loopback file..."
dd if=/dev/zero of="$LOOP_FILE" bs=1M count=256 status=progress 2>&1 || {
    dd if=/dev/zero of="$LOOP_FILE" bs=1M count=256
}
echo ""

echo "[2/6] Creating ext4 filesystem with journal..."
mkfs.ext4 -F -E lazy_itable_init=0 -J size=32 -O has_journal "$LOOP_FILE" 2>&1
echo ""

echo "[3/6] Mounting filesystem..."
mkdir -p "$MOUNT_POINT"
LOOP_DEV=$(sudo losetup --find --show "$LOOP_FILE")
echo "  Loop device: $LOOP_DEV"
sudo mount -o errors=remount-ro "$LOOP_DEV" "$MOUNT_POINT"
echo "  Mounted at: $MOUNT_POINT"
echo ""

echo "[4/6] Writing test data..."
sudo bash -c "echo 'Application data file 1' > ${MOUNT_POINT}/app_data_1.txt"
sudo bash -c "echo 'Application data file 2' > ${MOUNT_POINT}/app_data_2.txt"
sudo bash -c "echo 'Database WAL segment 001' > ${MOUNT_POINT}/wal_001.log"
sudo bash -c "dd if=/dev/urandom of=${MOUNT_POINT}/large_file.dat bs=1M count=50 2>/dev/null"
sudo bash -c "mkdir -p ${MOUNT_POINT}/data && touch ${MOUNT_POINT}/data/table_{1..10}.dat"
# Force sync to ensure data is written
sync
echo "  Written: app_data, wal, large_file (50MB), data tables"
echo ""

echo "[5/6] Corrupting the journal..."
# Find journal location and corrupt it
# First, flush everything
sync
sudo sync
# Get journal inode
JOURNAL_INODE=$(sudo debugfs -R "stat <8>" "$LOOP_DEV" 2>/dev/null | grep -o "Inode: [0-9]*" | head -1 || echo "")

# Unmount temporarily to corrupt, then remount
sudo umount "$MOUNT_POINT"

# Corrupt journal area directly in the image
# The journal is typically at blocks 1-8192 (depending on size)
# We'll corrupt specific bytes in the journal superblock and journal records
echo "  Corrupting journal superblock magic..."
# Journal superblock is typically at offset 1024 of the journal
# The ext4 journal magic number is at offset 0 of the journal block

# Find the journal start block
JOURNAL_START=$(sudo dumpe2fs "$LOOP_DEV" 2>/dev/null | grep "Journal start" | awk '{print $NF}')
BLOCK_SIZE=$(sudo dumpe2fs "$LOOP_DEV" 2>/dev/null | grep "Block size" | awk '{print $NF}')
JOURNAL_BLOCK=$(sudo dumpe2fs "$LOOP_DEV" 2>/dev/null | grep "Journal inode" | awk '{print $NF}' || echo "8")

echo "  Block size: ${BLOCK_SIZE:-4096}"
echo "  Journal inode: ${JOURNAL_BLOCK:-8}"

# Corrupt journal checksums by writing random bytes to journal area
# The journal typically starts after the superblock area
# We target offset ~128MB (middle of FS where journal usually lives)
JOURNAL_OFFSET=$((1024 + 4096))  # After superblock

# Write garbage to journal transaction headers
sudo dd if=/dev/urandom of="$LOOP_DEV" bs=1 count=512 seek=$((JOURNAL_OFFSET + 0)) conv=notrunc 2>/dev/null
sudo dd if=/dev/urandom of="$LOOP_DEV" bs=1 count=256 seek=$((JOURNAL_OFFSET + 4096)) conv=notrunc 2>/dev/null
sudo dd if=/dev/urandom of="$LOOP_DEV" bs=1 count=128 seek=$((JOURNAL_OFFSET + 8192)) conv=notrunc 2>/dev/null

# Also corrupt some of the orphan list
sudo dd if=/dev/urandom of="$LOOP_DEV" bs=1 count=64 seek=1080 conv=notrunc 2>/dev/null

echo "  Journal corruption applied."
echo ""

echo "[6/6] Remounting corrupted filesystem..."
# Remount — this should trigger ext4 error detection
sudo mount -o errors=remount-ro "$LOOP_DEV" "$MOUNT_POINT" 2>&1 || true

# Force a write to trigger journal replay failure
sleep 1
echo "  Attempting to write to mounted filesystem..."
sudo bash -c "echo 'test write after corruption' > ${MOUNT_POINT}/test_write.txt" 2>&1 || true
sync 2>/dev/null || true

# Check if it went read-only
sleep 1
MOUNT_OPTS=$(mount | grep "$LOOP_DEV" | grep -o "ro\|rw" | head -1)

echo ""
echo "============================================"
echo " FILESYSTEM STATE"
echo "============================================"
echo ""
echo "Mount point: $MOUNT_POINT"
echo "Loop device: $LOOP_DEV"
echo "Mount status: $(mount | grep "$LOOP_DEV" || echo 'not mounted')"
echo ""

if [[ "$MOUNT_OPTS" == "ro" ]] || ! sudo touch "${MOUNT_POINT}/write_test_$$" 2>/dev/null; then
    echo "✗ Filesystem is READ-ONLY (errors=remount-ro triggered)"
    echo ""
    echo "Simulated dmesg output:"
    echo "  [84723.456789] EXT4-fs error (device loop0): ext4_journal_check_start:83: "
    echo "                 Detected aborted journal"
    echo "  [84723.456790] EXT4-fs (loop0): Remounting filesystem read-only"
    echo "  [84723.456791] EXT4-fs error (device loop0): __ext4_journal_get_write_access:92:"
    echo "                 Detected aborted journal"
    echo "  [84723.890123] EXT4-fs (loop0): previous I/O error to superblock detected"
    echo "  [84723.890124] EXT4-fs warning (device loop0): ext4_end_bio:347: "
    echo "                 I/O error 10 writing to inode 12 starting block 1234"
else
    echo "! Filesystem is still read-write."
    echo "  The corruption may not have affected the active journal."
    echo "  Try: sudo touch ${MOUNT_POINT}/trigger_error"
    rm -f "${MOUNT_POINT}/write_test_$$" 2>/dev/null
fi

echo ""
echo "============================================"
echo " YOUR TASK:"
echo "  1. Identify the journal corruption in dmesg/mount output"
echo "  2. Determine why you can't fsck a mounted filesystem"
echo "  3. Safely unmount or stop processes using the mount"
echo "  4. Run fsck/e2fsck to repair the journal"
echo "  5. Remount read-write and verify data integrity"
echo ""
echo " Key info:"
echo "  Loop device: $LOOP_DEV"
echo "  Mount point: $MOUNT_POINT"
echo "  Loop file: $LOOP_FILE"
echo "============================================"
