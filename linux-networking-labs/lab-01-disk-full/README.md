## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (simulates the broken system state)
2. Investigate using standard Linux tools: `df`, `ps`, `ss`, `dmesg`, `journalctl`
3. Identify the root cause from system output
4. Apply the fix (the README hints at what's wrong)
5. Verify the system is healthy
6. Cleanup: `./cleanup.sh`. Check `solution.md` if stuck

---

# Lab 01: Disk Full — Deleted But Open Files

## Difficulty: 🟢 Easy

## Scenario

A production server is reporting disk space at near capacity. The operations team has already deleted large log files, but the space hasn't been freed. Applications are failing to write new data.

Your task: Find out why space isn't being reclaimed and free it without rebooting.

---

## What You'll See

### `df -h /tmp`
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        20G   18G  1.2G  94% /tmp
```

### `du -sh /tmp/*`
```
4.0K    /tmp/.lab01-simulate-running
304M    /tmp/lab01-bigfile1.dat
```
*(The deleted files won't show up in du or ls!)*

### `lsof +L1` (the key diagnostic)
```
COMMAND     PID   USER   FD   TYPE DEVICE   SIZE/OFF NLINK NODE NAME
bash      12345   root    3w   REG  253,1  209715200     0 1234 /tmp/lab01-deleted-openfile.dat (deleted)
tail      12346   root    3r   REG  253,1  157286400     0 1235 /tmp/lab01-hidden-log.dat (deleted)
```

---

## Hints

<details>
<summary>Hint 1</summary>
When a file is deleted but a process still has it open, the space isn't freed until the process releases the file descriptor. Use `lsof` to find deleted files.
</details>

<details>
<summary>Hint 2</summary>
The command `lsof +L1` shows all open files with a link count less than 1 (i.e., deleted files still held open by processes).
</details>

<details>
<summary>Hint 3</summary>
You can truncate a deleted-but-open file without killing the process: `echo "" > /proc/<PID>/fd/<FD>`. Or simply kill the offending process.
</details>

---

## Fix Commands

```bash
# Find deleted files still consuming space
lsof +L1

# Option A: Kill the process holding the file open
kill <PID_from_lsof>

# Option B: Truncate the open file descriptor without killing process
: > /proc/<PID>/fd/<FD>

# Remove remaining large files
rm -f /tmp/lab01-bigfile*.dat

# Verify space is freed
df -h /tmp
```

---

## Cleanup

```bash
sudo bash cleanup.sh
```
