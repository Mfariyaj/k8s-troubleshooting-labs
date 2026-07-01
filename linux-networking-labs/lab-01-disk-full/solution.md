# Solution: Lab 01 - Disk Full (Deleted-but-Open Files)

## Problem

The disk appears full (`df` shows 100% usage), but `du` reports less space used than expected.
This happens when large files are deleted but still held open by running processes.

## Diagnosis

```bash
# Check disk usage
df -h /

# Compare with actual file usage — notice the discrepancy
du -sh / 2>/dev/null

# Find deleted files still held open by processes
sudo lsof +L1

# Look for large deleted files specifically
sudo lsof +L1 | grep deleted | sort -k7 -n -r | head -20
```

## Root Cause

Processes opened large files which were then deleted from the filesystem. The kernel
keeps the file data on disk until the process releases the file descriptor. `df` counts
this space as used, but `ls`/`du` cannot see the files.

## Fix

### Option 1: Kill the processes holding deleted files

```bash
# Identify PIDs holding deleted files
sudo lsof +L1 | grep deleted | awk '{print $2}' | sort -u

# Kill the offending processes
sudo kill <PID>

# If graceful kill doesn't work
sudo kill -9 <PID>
```

### Option 2: Truncate the file via /proc (without killing the process)

```bash
# Find the PID and file descriptor number from lsof output
# Example: PID=1234, FD=4
sudo truncate -s 0 /proc/1234/fd/4
```

### Option 3: Restart the service properly

```bash
sudo systemctl restart rsyslog
```

## Verification

```bash
# Confirm disk space is freed
df -h /

# Verify no more deleted-but-open files
sudo lsof +L1 | grep deleted
```

## Prevention

- Use logrotate with `copytruncate` directive for log files
- Implement proper signal handling in applications to close file descriptors
- Monitor for deleted-but-open files using periodic `lsof +L1` checks
- Set up disk space alerts before reaching critical levels
