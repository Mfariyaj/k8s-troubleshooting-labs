# Solution: Lab 03 - Firewall Blocking Traffic

## Problem

Application is running and listening on port 8080, but connections from clients are
being refused or timing out. The service itself is healthy.

## Diagnosis

```bash
# Verify the application is listening
ss -tlnp | grep 8080

# Test local connectivity (this works)
curl localhost:8080

# Test remote connectivity (this fails)
curl <server-ip>:8080

# Check iptables rules for DROP/REJECT on port 8080
sudo iptables -L INPUT -n --line-numbers
sudo iptables -S INPUT | grep 8080
```

## Root Cause

An iptables rule is dropping incoming TCP traffic on port 8080:
```
-A INPUT -p tcp --dport 8080 -j DROP
```

## Fix

### Option 1: Delete the specific blocking rule

```bash
# Delete the DROP rule for port 8080
sudo iptables -D INPUT -p tcp --dport 8080 -j DROP

# If there are multiple rules, delete by line number
sudo iptables -L INPUT --line-numbers -n
sudo iptables -D INPUT <line-number>
```

### Option 2: Flush all iptables rules (use with caution)

```bash
sudo iptables -F INPUT
sudo iptables -P INPUT ACCEPT
```

### Option 3: Add an ACCEPT rule before the DROP rule

```bash
sudo iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT
```

## Verification

```bash
# Confirm the DROP rule is gone
sudo iptables -L INPUT -n | grep 8080

# Test connectivity
curl <server-ip>:8080
```

## Prevention

- Document all firewall rules and their purpose
- Use firewalld or ufw for easier rule management
- Persist rules with `iptables-save > /etc/iptables/rules.v4`
- Test connectivity after any firewall changes
