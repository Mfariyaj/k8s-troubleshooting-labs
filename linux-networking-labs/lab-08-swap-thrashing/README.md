## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (simulates the broken system state)
2. Investigate using standard Linux tools: `df`, `ps`, `ss`, `dmesg`, `journalctl`
3. Identify the root cause from system output
4. Apply the fix (the README hints at what's wrong)
5. Verify the system is healthy
6. Cleanup: `./cleanup.sh`. Check `solution.md` if stuck

---

# Lab 08: Swap Thrashing

## Difficulty: 🔴 Hard

## Scenario

The system is extremely slow. Users report that every operation takes 10x longer than normal. SSH sessions are sluggish, commands take seconds to respond. The system has not crashed, but it's barely functional. You suspect a memory issue causing heavy swap activity.

---

## What You'll See

### `free -m`
```
              total        used        free      shared  buff/cache   available
Mem:           3956        3612          52          12         291         132
Swap:          2048        1834         214
```
*(Very low free memory, heavy swap usage)*

### `vmstat 1 5`
```
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 3  2 1878016  53240   4096 298240  8432 12560 9856 13440  234  567 12  8  5 75  0
 4  1 1882112  48960   4096 294144 12800  8960 14208  9600  256  612 15  9  3 73  0
 2  3 1886208  45120   4096 290048  9600 11520 10880 12160  212  589 11  7  4 78  0
```
*(High `si`/`so` = swap in/out, high `wa` = waiting on I/O, high `b` = blocked processes)*

### `cat /proc/sys/vm/swappiness`
```
80
```
*(Very aggressive swapping — default is usually 60, production servers often use 10)*

### `sar -W 1 3` (if sysstat installed)
```
Average:     pswpin/s pswpout/s
Average:      8432.00  12560.00
```
*(Thousands of swap pages per second = thrashing)*

---

## Hints

<details>
<summary>Hint 1</summary>
Check `vmstat 1` — if `si` (swap in) and `so` (swap out) columns are consistently high (hundreds+), the system is thrashing. The `wa` (I/O wait) percentage will also be elevated.
</details>

<details>
<summary>Hint 2</summary>
Use `ps aux --sort=-%mem | head` to find which processes are consuming the most memory. The RSS column shows actual physical memory usage. Large RSS processes are the cause.
</details>

<details>
<summary>Hint 3</summary>
Short-term fix: Kill the memory-hogging processes. Medium-term: Reduce `vm.swappiness` with `sysctl vm.swappiness=10` (less aggressive swapping). Long-term: Add more RAM or set proper memory limits on processes.
</details>

---

## Fix Commands

```bash
# Identify memory hogs
ps aux --sort=-%mem | head -10

# Check swap activity
vmstat 1 5
swapon --show

# Kill memory-consuming processes
kill <PID1> <PID2> ...

# Reduce swappiness to prevent future thrashing
sudo sysctl vm.swappiness=10

# Make it permanent
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.d/99-swap.conf

# Clear swap (forces pages back to RAM if enough free RAM exists)
sudo swapoff -a && sudo swapon -a

# Verify system is recovered
free -m
vmstat 1 3
```

---

## Cleanup

```bash
sudo bash cleanup.sh
```
