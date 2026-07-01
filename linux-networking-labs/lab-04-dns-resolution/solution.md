# Solution: Lab 04 - DNS Resolution Failure

## Problem

DNS lookups fail for all external domains. Commands like `ping google.com`,
`curl https://example.com`, or `nslookup` return resolution errors.

## Diagnosis

```bash
# Test DNS resolution
nslookup google.com
dig google.com

# Check current resolv.conf
cat /etc/resolv.conf

# Check if resolv.conf is empty or has invalid nameservers
grep nameserver /etc/resolv.conf

# Test with a known-good DNS server directly
dig @8.8.8.8 google.com

# Check if systemd-resolved is running
systemctl status systemd-resolved
```

## Root Cause

The `/etc/resolv.conf` file is either empty, contains invalid nameserver entries,
or points to a non-responsive DNS server. Without valid nameserver configuration,
the system cannot resolve domain names.

## Fix

### Restore resolv.conf with correct nameservers

```bash
sudo tee /etc/resolv.conf << EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
EOF
```

### If using systemd-resolved

```bash
sudo systemctl restart systemd-resolved
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
```

### If using NetworkManager

```bash
sudo nmcli connection modify <connection-name> ipv4.dns "8.8.8.8 8.8.4.4"
sudo nmcli connection up <connection-name>
```

## Verification

```bash
# Test DNS resolution
nslookup google.com
dig google.com +short
ping -c 3 google.com
```

## Prevention

- Protect resolv.conf with `chattr +i /etc/resolv.conf` if manually managed
- Use DHCP-provided DNS or configure via NetworkManager/netplan
- Set up a local DNS cache (dnsmasq, systemd-resolved) for resilience
- Monitor DNS resolution as part of health checks
