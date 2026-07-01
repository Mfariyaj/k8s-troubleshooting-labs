# Lab 06: Memory Leak / OOM Killer

## Difficulty: 🟡 Medium

## Scenario

Production alerts show a service is consuming an abnormal amount of memory. The system is under memory pressure. Applications are slow and unresponsive. You need to identify the leaking process, understand the OOM killer mechanism, and stabilize the system.

---

## What You'll See

### `free -m`
```
              total        used        free      shared  buff/cache   available
Mem:           3956        3401         123          42         431         312
Swap:          2048        1456         592
```

### `ps aux --sort=-%mem | head -5`
```
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root     18432 15.3 12.5 534612 512000 pts/0   Sl   10:23   0:45 python3 memory-hog.py
root      1234  0.5  1.2  45612  49152 ?       Ss   09:00   0:12 /usr/sbin/mysqld
www-data  2345  0.2  0.8  23456  32768 ?       S    09:01   0:03 nginx: worker
```

### `dmesg | grep -i "oom\|killed"` (if OOM has triggered)
```
[  423.456789] memory-hog.py invoked oom-killer: gfp_mask=0x100cca(GFP_HIGHUSER_MOVABLE)
[  423.456790] Out of memory: Killed process 18432 (python3) total-vm:534612kB, anon-rss:512000kB
[  423.456791] oom_reaper: reaped process 18432 (python3), now anon-rss:0kB
```

### `cat /proc/<PID>/status | grep -i vm`
```
VmPeak:	  534612 kB
VmSize:	  534612 kB
VmRSS:	   512000 kB
VmSwap:	    12340 kB
```

---

## Hints

<details>
<summary>Hint 1</summary>
Use `ps aux --sort=-%mem | head` or `top -o %MEM` to find the process consuming the most memory. Look at the RSS (Resident Set Size) column for actual physical memory usage.
</details>

<details>
<summary>Hint 2</summary>
Check `/proc/<PID>/status` for detailed memory info, and `/proc/<PID>/smaps` for memory mapping details. The `VmRSS` field shows actual RAM usage.
</details>

<details>
<summary>Hint 3</summary>
To stop the bleeding: kill the process (`kill <PID>`). For long-term fix: set memory limits using cgroups, systemd resource controls (`MemoryMax=`), or `ulimit`. Check `dmesg` for OOM events.
</details>

---

## Fix Commands

```bash
# Identify the memory hog
ps aux --sort=-%mem | head -5

# Check memory details of suspicious process
cat /proc/<PID>/status | grep -i vm

# Kill the leaking process
kill <PID>

# Verify memory is freed
free -m

# Long-term fix: Set memory limits in systemd service file
# MemoryMax=256M in [Service] section

# Check OOM killer history
dmesg | grep -i "oom\|killed"
```

---

## Cleanup

```bash
sudo bash cleanup.sh
```
