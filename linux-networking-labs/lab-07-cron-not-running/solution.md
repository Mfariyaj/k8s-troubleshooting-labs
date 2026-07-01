# Solution: Lab 07 - Cron Job Not Running

## Problem

A scheduled cron job is configured but never executes. No output, no logs, no evidence
of the script running at the expected times.

## Diagnosis

```bash
# Check the crontab
crontab -l

# Check system cron logs
grep CRON /var/log/syslog
journalctl -u cron --since "1 hour ago"

# Check if cron daemon is running
systemctl status cron

# Try running the script manually
bash /path/to/script-to-run.sh
```

## Root Cause

Multiple issues in the crontab:

1. **Missing PATH**: Cron uses minimal PATH (`/usr/bin:/bin`). Custom binaries aren't found.
2. **Unescaped `%` characters**: In crontab, `%` is a newline delimiter. Must escape as `\%`.
3. **Missing SHELL**: Default cron shell may be `/bin/sh`, lacking bash features.

## Fix

### Fix the crontab

```bash
crontab -e
```

Apply these corrections:

```cron
# Set proper environment
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Escape % characters in the command
# BROKEN:  * * * * * /path/to/script.sh --date=$(date +%Y-%m-%d)
# FIXED:
* * * * * /path/to/script.sh --date=$(date +\%Y-\%m-\%d)

# Redirect output to capture errors:
* * * * * /path/to/script-to-run.sh >> /tmp/cron.log 2>&1
```

### Ensure the script is executable

```bash
chmod +x /path/to/script-to-run.sh
```

## Verification

```bash
# Wait for next execution and check logs
grep CRON /var/log/syslog | tail -5

# Check output log if configured
cat /tmp/cron.log
```

## Prevention

- Always set `SHELL` and `PATH` at the top of crontab files
- Escape all `%` characters in cron commands
- Redirect stdout/stderr to a log file for debugging
- Test scripts in minimal environment: `env -i /bin/sh -c "your-command"`
