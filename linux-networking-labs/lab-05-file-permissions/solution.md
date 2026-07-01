# Solution: Lab 05 - File Permission Issues

## Problem

An application fails to read its configuration file or write to its data directory
due to incorrect file permissions and/or ownership.

## Diagnosis

```bash
# Check the file permissions and ownership
ls -la /path/to/config.conf

# Check what user the application runs as
ps aux | grep <app-name>

# Test access as the application user
sudo -u <app-user> cat /path/to/config.conf

# Check directory permissions too
ls -la /path/to/

# Look at application error messages
journalctl -u <service-name> --no-pager -n 20
```

## Root Cause

The configuration file has incorrect permissions (e.g., `600` owned by root, or `000`)
preventing the application user from reading it. The ownership may be set to root
instead of the application's service account.

## Fix

### Step 1: Fix file permissions

```bash
# Set readable permissions (owner read/write, group/others read)
sudo chmod 644 /path/to/config.conf

# For sensitive configs (readable by owner and group only)
sudo chmod 640 /path/to/config.conf
```

### Step 2: Fix file ownership

```bash
# Change ownership to the correct user and group
sudo chown correct-user:correct-group /path/to/config.conf

# Fix directory ownership recursively if needed
sudo chown -R correct-user:correct-group /path/to/app-dir/
```

### Step 3: Restart the application

```bash
sudo systemctl restart <service-name>
```

## Verification

```bash
# Confirm permissions are correct
ls -la /path/to/config.conf

# Test access as the app user
sudo -u correct-user cat /path/to/config.conf

# Verify application starts successfully
sudo systemctl status <service-name>
```

## Prevention

- Use configuration management (Ansible/Puppet) to enforce permissions
- Set umask appropriately for service accounts
- Use systemd directives like `ConfigurationDirectory=`
- Implement file permission auditing with tools like `aide`
