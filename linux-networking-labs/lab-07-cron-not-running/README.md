## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (simulates the broken system state)
2. Investigate using standard Linux tools: `df`, `ps`, `ss`, `dmesg`, `journalctl`
3. Identify the root cause from system output
4. Apply the fix (the README hints at what's wrong)
5. Verify the system is healthy
6. Cleanup: `./cleanup.sh`. Check `solution.md` if stuck

---

# Lab 07: Cron Not Running

## Difficulty: 🟡 Medium

## Scenario

The operations team set up a cron job to run a backup script every minute. The script works perfectly when run manually, but the cron job never produces any output. No backup files are being created. The team needs you to figure out why cron is silently failing.

---

## What You'll See

### `crontab -l`
```
# Broken crontab - Multiple issues prevent execution
# Issue 1: Wrong PATH - commands won't be found
PATH=/nonexistent/bin

# Issue 2: Missing SHELL definition (not critical but compounds issues)

# Issue 3: The % character is not escaped - cron interprets % as newline
* * * * * /opt/lab07-scripts/script-to-run.sh --date=$(date +%Y-%m-%d) --format=%H:%M > /tmp/lab07-output.log 2>&1

# Issue 4: This script path doesn't exist (typo in path)
*/5 * * * * /opt/lab07-script/backup.sh > /tmp/lab07-backup.log 2>&1

# Issue 5: Six fields instead of five (extra field makes it invalid)
* * * * * * echo "health check" > /tmp/lab07-health.log
```

### `grep CRON /var/log/syslog` (or `journalctl -u cron`)
```
Jul  1 10:01:01 server CRON[12345]: (root) CMD (/opt/lab07-scripts/script-to-run.sh --date=$(date +)
Jul  1 10:01:01 server CRON[12345]: (CRON) info (No MTA installed, discarding output)
```
*(Notice the command is truncated at the first unescaped `%`)*

---

## Hints

<details>
<summary>Hint 1</summary>
In crontab, the `%` character has special meaning — it represents a newline. Any `%` in a command must be escaped as `\%`. This is the #1 reason cron commands silently fail.
</details>

<details>
<summary>Hint 2</summary>
Cron runs with a minimal environment. The `PATH` variable is set to `/nonexistent/bin` which means no system commands can be found. Set PATH correctly at the top: `PATH=/usr/local/bin:/usr/bin:/bin`
</details>

<details>
<summary>Hint 3</summary>
Check `/var/log/syslog` or `journalctl -u cron` for cron execution logs. If you see "No MTA installed, discarding output" — the job ran but errored, and the error email couldn't be sent. Always redirect both stdout and stderr in cron jobs.
</details>

---

## Fix Commands

```bash
# Edit the crontab
crontab -e

# Fixed crontab should look like:
# PATH=/usr/local/bin:/usr/bin:/bin
# SHELL=/bin/bash
#
# Escape all % characters with \%
# * * * * * /opt/lab07-scripts/script-to-run.sh --date=$(date +\%Y-\%m-\%d) --format=\%H:\%M > /tmp/lab07-output.log 2>&1
#
# Fix typo in path: lab07-script → lab07-scripts
# */5 * * * * /opt/lab07-scripts/backup.sh > /tmp/lab07-backup.log 2>&1
#
# Fix 6-field entry (remove extra asterisk)
# * * * * * echo "health check" > /tmp/lab07-health.log

# Verify cron service is running
systemctl status cron

# Wait 1 minute, then check output
sleep 65 && cat /tmp/lab07-output.log
```

---

## Cleanup

```bash
sudo bash cleanup.sh
```
