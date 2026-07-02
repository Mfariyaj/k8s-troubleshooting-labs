## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (simulates the broken system state)
2. Investigate using standard Linux tools: `df`, `ps`, `ss`, `dmesg`, `journalctl`
3. Identify the root cause from system output
4. Apply the fix (the README hints at what's wrong)
5. Verify the system is healthy
6. Cleanup: `./cleanup.sh`. Check `solution.md` if stuck

---

# Lab 15: Filesystem Journal Corruption — Read-Only Emergency

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

A production application server's root filesystem has suddenly remounted **read-only** at 3:47 AM. All write operations are failing, the application is returning 500 errors, and log rotation has stopped. The monitoring system shows ext4 errors in dmesg.

The filesystem was mounted with `errors=remount-ro` (the safe default), so when the kernel detected journal corruption, it flipped the filesystem to read-only to prevent further damage. But now:
- The application can't write temp files, sessions, or logs
- You can't run `fsck` because the filesystem is still mounted
- You can't unmount because processes have open files on it
- The underlying issue is journal checksum corruption from a storage controller firmware bug

## Environment

- **OS**: Ubuntu 22.04 LTS (Kernel 5.15)
- **Filesystem**: ext4, 500GB on /dev/sda3 (mounted as /data)
- **Application**: Java service writing WAL + data files to /data
- **Storage**: Dell PERC H740P RAID controller (firmware v5.16.00-3538 — known journal corruption bug)
- **Mount options**: `rw,relatime,errors=remount-ro,data=ordered`

## Symptoms Observed

### Application errors:
```
2024-03-15 03:47:23 ERROR [main] — IOException: Read-only file system
2024-03-15 03:47:23 ERROR [wal-writer] — Cannot write WAL segment: /data/wal/segment_0x000234.log
    java.io.IOException: Read-only file system
2024-03-15 03:47:24 ERROR [session-mgr] — Failed to persist session: /data/sessions/sess_a3b2c1d4
2024-03-15 03:47:24 FATAL [main] — Application shutting down: filesystem is read-only
```

### dmesg output:
```
[84721.234567] EXT4-fs error (device sda3): ext4_journal_check_start:83: Detected aborted journal
[84721.234568] EXT4-fs (sda3): Remounting filesystem read-only
[84721.345678] EXT4-fs error (device sda3): ext4_journal_check_start:83: Detected aborted journal
[84721.456789] EXT4-fs error (device sda3): __ext4_journal_get_write_access:92: Detected aborted journal
[84721.567890] EXT4-fs (sda3): previous I/O error to superblock detected
[84721.678901] EXT4-fs warning (device sda3): ext4_end_bio:347: I/O error 10 writing to inode 12 (offset 0 size 4096 starting block 234567)
[84721.789012] Buffer I/O error on device sda3, logical block 1048576
[84721.890123] EXT4-fs error (device sda3) in ext4_reserve_inode_write:5763: Journal has aborted
[84722.123456] JBD2: recovery pass 'scan' failed with error -22 on journal device sda3-8
[84722.234567] JBD2: journal checksum error found in transaction 48923 (expected 0xab3f1234, got 0x00000000)
[84722.345678] EXT4-fs (sda3): error loading journal
```

### mount output:
```
$ mount | grep sda3
/dev/sda3 on /data type ext4 (ro,relatime,errors=remount-ro,data=ordered)

$ # Note: Was originally mounted rw, now showing 'ro'!
```

### Attempting writes:
```
$ touch /data/test
touch: cannot touch '/data/test': Read-only file system
$ echo "test" > /data/test
bash: /data/test: Read-only file system
```

### Attempting unmount:
```
$ sudo umount /data
umount: /data: target is busy.
$ sudo umount -l /data
umount: /data: target is busy.
        (In some cases useful info about processes that use
         the device is found by lsof(8) or fuser(1))
```

### Processes using the filesystem:
```
$ sudo fuser -vm /data
                     USER        PID ACCESS COMMAND
/data:               root     kernel mount /data
                     app       4521 F...m java
                     app       4522 F.... java
                     app       4523 F...m java
                     root      1234 F.... rsyslogd
                     root      5678 F.... logrotate
```

### Attempting fsck while mounted:
```
$ sudo e2fsck /dev/sda3
e2fsck 1.46.5 (30-Dec-2021)
/dev/sda3 is mounted.
e2fsck: Cannot continue, aborting.
```

### dumpe2fs shows journal issues:
```
$ sudo dumpe2fs -h /dev/sda3 2>/dev/null | grep -i journal
Filesystem features:      has_journal ext_attr resize_inode dir_index filetype needs_recovery extent 64bit flex_bg sparse_super large_file huge_file dir_nlink extra_isize metadata_csum
Journal inode:            8
Journal backup:           inode blocks
Journal features:         journal_incompat_revoke journal_64bit journal_checksum_v3
Journal size:             128M
Journal length:           32768
Journal sequence:         0x0000bf23
Journal start:            1
Journal errno:            -22
```
*Note: `Journal errno: -22` (EINVAL) and `needs_recovery` flag set!*

### debugfs inspection:
```
$ sudo debugfs -R "stat <8>" /dev/sda3
Inode: 8   Type: regular    Mode:  0600   Flags: 0x80000
Size: 134217728   (128MB journal)
Blocks: 262144
Fragment: Address: 0    Number: 0    Size: 0
EXTENTS:
(0-32767): 33554432-33587199
```

### strace showing errors:
```
$ strace -p 4521 -e write
write(12, "WAL segment data...", 8192) = -1 EROFS (Read-only file system)
write(12, "WAL segment data...", 8192) = -1 EROFS (Read-only file system)
write(15, "session data...", 4096) = -1 EROFS (Read-only file system)
```

## Your Task

1. Identify the root cause from dmesg (journal checksum corruption)
2. Determine why you can't simply `fsck` (filesystem is mounted)
3. Gracefully stop processes using the filesystem
4. Unmount the filesystem (or handle the "busy" condition)
5. Run `e2fsck` to repair journal corruption
6. Remount the filesystem read-write
7. Verify data integrity after repair
8. Optionally: recreate journal if repair fails

## Useful Commands

```bash
# View ext4 errors
dmesg | grep -i "ext4\|journal\|jbd2"
journalctl -k | grep -i "ext4\|journal"

# Check mount status
mount | grep /data
cat /proc/mounts | grep /data

# Find processes using filesystem
fuser -vm /data
lsof +D /data | head -20

# Gracefully stop processes
fuser -k /data          # Send SIGKILL to all processes
# Or better:
fuser -TERM /data       # Send SIGTERM first

# Force unmount (lazy unmount)
umount -l /data

# Force unmount (when lazy fails)
umount -f /data

# Check filesystem before fsck
dumpe2fs -h /dev/sda3 | grep -i "journal\|state\|error"
tune2fs -l /dev/sda3 | grep -i "state\|error\|mount"

# Run filesystem check
e2fsck -f -y /dev/sda3          # Force check, auto-yes
e2fsck -f -y -C 0 /dev/sda3    # With progress indicator

# If journal is completely broken, rebuild it
e2fsck -f -y /dev/sda3          # Repair what we can
tune2fs -O ^has_journal /dev/sda3  # Remove journal
tune2fs -j /dev/sda3              # Recreate journal

# Remount read-write
mount -o remount,rw /data

# Verify after repair
dumpe2fs -h /dev/sda3 | grep "Filesystem state"
# Should show: "Filesystem state: clean"

# Check for data loss
find /data -newer /data/last_known_good -type f

# Prevent future issues — change mount option
# In /etc/fstab, consider: errors=continue (risky) vs errors=remount-ro (safe)
```

## Hints

<details>
<summary>Hint 1</summary>
You cannot run <code>e2fsck</code> on a mounted filesystem — period. You MUST unmount first. The issue is processes have open file handles. Use <code>fuser -vm /data</code> to find them, gracefully stop the application (SIGTERM), then kill remaining processes. Once all handles are released, <code>umount /data</code> will succeed. If it's truly stuck, <code>umount -l /data</code> does a lazy unmount (detaches from namespace, completes when last fd closes).
</details>

<details>
<summary>Hint 2</summary>
The <code>Journal errno: -22</code> in <code>dumpe2fs</code> output means the journal encountered an invalid argument error (corrupt checksum). <code>e2fsck -f -y /dev/sda3</code> will attempt to repair. If the journal is too corrupted, you may need to remove and recreate it: <code>tune2fs -O ^has_journal /dev/sda3 && tune2fs -j /dev/sda3</code>. This recreates a clean journal but you lose any uncommitted transactions.
</details>

<details>
<summary>Hint 3</summary>
After repair, check <code>dumpe2fs -h /dev/sda3 | grep "Filesystem state"</code> — it should say "clean". Mount with <code>mount -o rw,relatime,errors=remount-ro</code> and verify writes work with <code>touch /data/test && rm /data/test</code>. Also investigate the root cause: check storage controller firmware (<code>megacli</code>, <code>perccli</code>), SMART data (<code>smartctl -a /dev/sda</code>), and dmesg for prior I/O errors that caused the journal corruption.
</details>

## Root Causes

This lab demonstrates **ext4 journal corruption recovery**, involving:

1. **Journal checksum mismatch** — Storage firmware bug caused silent data corruption in the journal area. The JBD2 layer detected the invalid checksum and aborted the journal.

2. **`errors=remount-ro` triggered** — This mount option (the safe default) makes ext4 flip to read-only when any filesystem error is detected, preventing further corruption but blocking all writes.

3. **Can't fsck while mounted** — `e2fsck` refuses to run on a mounted filesystem because modifying filesystem metadata while it's in use would cause catastrophic corruption.

4. **Orphan inode list corrupted** — Besides the journal, the orphan list (inodes being deleted when the system crashed) is also corrupted, which `e2fsck` must clean up.

5. **Recovery procedure**:
   - Stop all processes using the filesystem
   - Unmount the filesystem
   - Run `e2fsck -f -y` to repair journal and orphans
   - If journal is unrecoverable: remove and recreate it
   - Remount read-write
   - Verify data integrity
   - Fix root cause (firmware update)
