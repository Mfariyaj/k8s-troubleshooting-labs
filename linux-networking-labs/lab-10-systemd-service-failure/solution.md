# Solution: Lab 10 - Systemd Service Failure

## Problem

A systemd service fails to start, enters a "failed" state, and hits the start rate
limit ("Start request repeated too quickly").

## Diagnosis

```bash
# Check service status
sudo systemctl status broken-app.service

# View detailed logs
sudo journalctl -u broken-app.service --no-pager -n 50

# Inspect the unit file
sudo systemctl cat broken-app.service

# Check for start limit
sudo systemctl show broken-app.service | grep -i startlimit

# Verify the binary/script path exists
ls -la /path/to/ExecStart/binary
```

## Root Cause

Multiple issues in the systemd unit file:

1. **Wrong ExecStart path**: The binary path doesn't exist or is incorrect.
2. **Wrong Type**: Using `Type=forking` when the process doesn't fork (should be `simple`).
3. **StartLimitBurst too low**: Service crashes and hits restart limit too quickly.

## Fix

### Step 1: Fix the ExecStart path

```ini
# BROKEN:  ExecStart=/usr/local/bin/broken-app
# FIXED:
ExecStart=/opt/app/app.sh
```

### Step 2: Change Type to simple

```ini
# BROKEN:  Type=forking
# FIXED:
Type=simple
```

### Step 3: Increase StartLimitBurst

```ini
StartLimitBurst=5
StartLimitIntervalSec=60
Restart=on-failure
RestartSec=5
```

### Step 4: Apply changes

```bash
sudo systemctl daemon-reload
sudo systemctl reset-failed broken-app.service
sudo systemctl start broken-app.service
```

## Verification

```bash
sudo systemctl status broken-app.service
sleep 10 && sudo systemctl is-active broken-app.service
sudo journalctl -u broken-app.service -f
```

## Prevention

- Test unit files with `systemd-analyze verify <unit-file>`
- Use `ExecStartPre=` to validate prerequisites
- Use `Type=simple` unless the process genuinely double-forks
- Use absolute paths in all ExecStart directives
