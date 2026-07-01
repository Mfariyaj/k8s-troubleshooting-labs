# Lab 04: DNS Resolution Failure

## Difficulty: 🟡 Medium

## Scenario

After a network infrastructure change, multiple services on the server are reporting DNS resolution failures. Applications can't connect to external APIs or databases by hostname. Direct IP connectivity seems fine (you can ping `8.8.8.8`). The networking team says "nothing changed on our end."

---

## What You'll See

### `dig google.com`
```
; <<>> DiG 9.16.1 <<>> google.com
;; global options: +cmd
;; connection timed out; no servers could be reached
```

### `nslookup google.com`
```
;; connection timed out; no servers could be reached
```

### `ping -c 1 8.8.8.8`
```
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=117 time=12.3 ms
--- 8.8.8.8 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss
```
*(IP connectivity works — only DNS is broken)*

### `cat /etc/resolv.conf`
```
# This file was updated by the network team
# Nameserver configuration - DO NOT EDIT
nameserver 192.0.2.1
nameserver 198.51.100.1
options timeout:1 attempts:1
```

---

## Hints

<details>
<summary>Hint 1</summary>
If `ping` works with an IP but DNS fails, the issue is between your system and DNS resolution. Check what DNS servers your system is configured to use.
</details>

<details>
<summary>Hint 2</summary>
DNS configuration is in `/etc/resolv.conf`. Check if the nameservers listed there are actually reachable. Try `dig @8.8.8.8 google.com` to test with a known-good nameserver.
</details>

<details>
<summary>Hint 3</summary>
The IP ranges `192.0.2.0/24` (TEST-NET-1) and `198.51.100.0/24` (TEST-NET-2) are documentation-only ranges per RFC 5737 — they are never routable on the internet.
</details>

---

## Fix Commands

```bash
# Test with a known-good DNS server to confirm the problem is local config
dig @8.8.8.8 google.com

# Check current DNS configuration
cat /etc/resolv.conf

# Fix: Replace with valid nameservers
sudo bash -c 'cat > /etc/resolv.conf << EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF'

# Verify DNS works
dig google.com
nslookup google.com
```

---

## Cleanup

```bash
sudo bash cleanup.sh
```
