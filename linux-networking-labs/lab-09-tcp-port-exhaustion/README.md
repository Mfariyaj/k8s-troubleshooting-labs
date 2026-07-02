## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (simulates the broken system state)
2. Investigate using standard Linux tools: `df`, `ps`, `ss`, `dmesg`, `journalctl`
3. Identify the root cause from system output
4. Apply the fix (the README hints at what's wrong)
5. Verify the system is healthy
6. Cleanup: `./cleanup.sh`. Check `solution.md` if stuck

---

# Lab 09: TCP Port Exhaustion

## Difficulty: 🔴 Hard

## Scenario

Application teams are reporting intermittent connection failures. Services that connect to databases, APIs, and microservices are getting "Cannot assign requested address" errors. The problem started after a traffic spike and isn't resolving itself. You need to identify why new TCP connections are failing.

---

## What You'll See

### `ss -s`
```
Total: 1847
TCP:   952 (estab 908, closed 12, orphaned 3, timewait 29)

Transport Total     IP        IPv6
RAW       0         0         0
UDP       4         3         1
TCP       952       950       2
INET      956       953       3
FRAG      0         0         0
```

### `ss -tn | wc -l`
```
952
```

### `cat /proc/sys/net/ipv4/ip_local_port_range`
```
50000	51000
```
*(Only 1000 ephemeral ports available! Default should be 32768-60999)*

### Trying to make a new connection:
```bash
$ curl http://localhost:19999
curl: (7) Failed to connect: Cannot assign requested address
```

### `ss -tn state established | awk '{print $4}' | cut -d: -f2 | sort -n | tail`
```
50991
50993
50995
50997
50998
50999
51000
```
*(Ports exhausted up to the maximum)*

---

## Hints

<details>
<summary>Hint 1</summary>
"Cannot assign requested address" means the kernel can't find a free ephemeral port for the outgoing connection. Check the available port range with `cat /proc/sys/net/ipv4/ip_local_port_range`.
</details>

<details>
<summary>Hint 2</summary>
The ephemeral port range has been narrowed to only 1000 ports (50000-51000). The default Linux range is 32768-60999 (~28000 ports). Additionally, a process is holding many connections open, consuming all available ports.
</details>

<details>
<summary>Hint 3</summary>
Short-term: Kill the process holding open connections (`ss -tnp` shows which PID owns them). Then widen the port range: `sysctl net.ipv4.ip_local_port_range="32768 60999"`. Also consider enabling `net.ipv4.tcp_tw_reuse=1` for TIME_WAIT recycling.
</details>

---

## Fix Commands

```bash
# Diagnose: check port range
cat /proc/sys/net/ipv4/ip_local_port_range

# See what's holding all the connections
ss -tnp | head -20

# Identify the offending process
ss -tnp | grep -oP 'pid=\K[0-9]+' | sort | uniq -c | sort -rn | head

# Kill the offending process
kill <PID>

# Widen the ephemeral port range (immediate fix)
sudo sysctl net.ipv4.ip_local_port_range="32768 60999"

# Enable TIME_WAIT reuse for faster port recycling
sudo sysctl net.ipv4.tcp_tw_reuse=1

# Make persistent
echo "net.ipv4.ip_local_port_range = 32768 60999" | sudo tee -a /etc/sysctl.d/99-ports.conf
echo "net.ipv4.tcp_tw_reuse = 1" | sudo tee -a /etc/sysctl.d/99-ports.conf
sudo sysctl -p /etc/sysctl.d/99-ports.conf

# Verify
ss -s
cat /proc/sys/net/ipv4/ip_local_port_range
```

---

## Cleanup

```bash
sudo bash cleanup.sh
```
