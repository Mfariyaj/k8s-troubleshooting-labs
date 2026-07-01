# Solution: Lab 15 - Filesystem Journal Corruption

## Problem

A filesystem is mounted read-only or refuses to mount due to journal corruption.
Applications fail with "Read-only file system" errors.

## Diagnosis

```bash
# Check mount status
mount | grep <device>

# Look for filesystem errors in dmesg
dmesg | grep -i "ext4\|journal\|error\|read-only"

# Check filesystem state
tune2fs -l /dev/sdX | grep "Filesystem state"

# Check if remount was forced to read-only
journalctl -k | grep -i "remount\|read-only\|EXT4-fs error"
```

## Root Cause

The filesystem's journal became corrupted (power loss, disk error, kernel bug).
The kernel detected inconsistency and remounted the filesystem as read-only to
prevent further data corruption.

## Fix

### Step 1: Unmount the filesystem

```bash
# Try to unmount cleanly
sudo umount /mnt/data

# If busy, find and stop processes using it
sudo lsof +D /mnt/data
sudo fuser -km /mnt/data
sudo umount /mnt/data
```

### Step 2: Run fsck to repair the filesystem

```bash
# Run filesystem check with automatic repair
sudo fsck -y /dev/sdX

# For ext4 specifically
sudo e2fsck -yf /dev/sdX

# If journal is severely corrupted, rebuild it
sudo e2fsck -y /dev/sdX
# If that fails:
sudo tune2fs -O ^has_journal /dev/sdX
sudo e2fsck -y /dev/sdX
sudo tune2fs -j /dev/sdX
```

### Step 3: Remount the filesystem read-write

```bash
# Mount normally
sudo mount /dev/sdX /mnt/data

# Or remount if already mounted read-only
sudo mount -o remount,rw /dev/sdX /mnt/data
```

## Verification

```bash
# Confirm read-write mount
mount | grep /mnt/data

# Test write access
touch /mnt/data/test-file && rm /mnt/data/test-file

# Check filesystem state is clean
sudo tune2fs -l /dev/sdX | grep "Filesystem state"
```

## Prevention

- Use UPS/battery backup to prevent unclean shutdowns
- Enable `barrier=1` mount option for write ordering guarantees
- Schedule periodic fsck via tune2fs mount counts
- Monitor disk health with SMART (smartctl)
- Keep filesystem backups for recovery scenarios
