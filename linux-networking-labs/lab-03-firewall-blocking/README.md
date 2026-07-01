# Lab 03: Firewall Blocking

## Difficulty: 🟡 Medium

## Scenario

The development team deployed a new HTTP application server on port 8080. The process is confirmed running, and nothing else is using that port. However, users report connection timeouts when trying to access the service. The server worked yesterday before a "security hardening" was applied.

---

## What You'll See

### `curl -m 5 http://localhost:8080`
```
curl: (28) Connection timed out after 5001 milliseconds
```

### `ss -tlnp | grep 8080`
```
LISTEN  0  5  0.0.0.0:8080  0.0.0.0:*  users:(("python3",pid=12345,fd=4))
```
*(Server IS listening — the problem is elsewhere)*

### `iptables -L -n -v`
```
Chain INPUT (policy ACCEPT 1234 packets, 98765 bytes)
 pkts bytes target  prot opt in  out  source       destination
   12   720 DROP    tcp  --  *   *    0.0.0.0/0    0.0.0.0/0    tcp dpt:8080

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target  prot opt in  out  source       destination

Chain OUTPUT (policy ACCEPT 1234 packets, 98765 bytes)
 pkts bytes target  prot opt in  out  source       destination
```

---

## Hints

<details>
<summary>Hint 1</summary>
If a service is listening (`ss` confirms it) but `curl` times out (not "connection refused"), think about what sits between the client and the server — firewalls, security groups, or packet filters.
</details>

<details>
<summary>Hint 2</summary>
Check `iptables -L -n -v` for any DROP or REJECT rules on port 8080. The `-v` flag shows packet counters which confirm if the rule is actively dropping traffic.
</details>

<details>
<summary>Hint 3</summary>
Remove the offending rule with `iptables -D INPUT -p tcp --dport 8080 -j DROP`. You can also list rules with line numbers using `iptables -L INPUT --line-numbers` and delete by number.
</details>

---

## Fix Commands

```bash
# Confirm the server is listening
ss -tlnp | grep 8080

# Check firewall rules
iptables -L INPUT -n -v --line-numbers

# Remove the DROP rule (by specification)
sudo iptables -D INPUT -p tcp --dport 8080 -j DROP

# Or remove by line number
sudo iptables -D INPUT <line_number>

# Verify access is restored
curl http://localhost:8080
```

---

## Cleanup

```bash
sudo bash cleanup.sh
```
