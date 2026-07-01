# Lab 10: Systemd Service Failure

## Difficulty: 🔴 Hard

## Scenario

A new application was packaged as a systemd service. The application binary runs perfectly when executed directly (`/usr/local/bin/lab10-app`), but the systemd service keeps failing to start. After several restart attempts, systemd reports it has hit the start rate limit. The on-call engineer needs to identify all issues in the service unit file and get the service running.

---

## What You'll See

### `systemctl status lab10-app`
```
● lab10-app.service - Lab 10 Broken Application Service
     Loaded: loaded (/etc/systemd/system/lab10-app.service; disabled; vendor preset: enabled)
     Active: failed (Result: start-limit-hit) since Wed 2026-07-01 10:23:45 UTC; 2min ago
    Process: 14523 ExecStart=/usr/loca/bin/lab10-app (code=exited, status=203/EXEC)
   Main PID: 14523 (code=exited, status=203/EXEC)
        CPU: 2ms

Jul 01 10:23:45 server systemd[1]: lab10-app.service: Scheduled restart job, restart counter is at 3.
Jul 01 10:23:45 server systemd[1]: Stopped Lab 10 Broken Application Service.
Jul 01 10:23:45 server systemd[1]: lab10-app.service: Start request repeated too quickly.
Jul 01 10:23:45 server systemd[1]: lab10-app.service: Failed with result 'start-limit-hit'.
Jul 01 10:23:45 server systemd[1]: Failed to start Lab 10 Broken Application Service.
```

### `journalctl -u lab10-app --no-pager`
```
Jul 01 10:23:42 server systemd[1]: Starting Lab 10 Broken Application Service...
Jul 01 10:23:42 server systemd[14520]: lab10-app.service: Failed to determine supplementary groups: No such process
Jul 01 10:23:42 server systemd[14520]: lab10-app.service: Failed at step EXEC spawning /usr/loca/bin/lab10-app: No such file or directory
Jul 01 10:23:42 server systemd[1]: lab10-app.service: Main process exited, code=exited, status=203/EXEC
Jul 01 10:23:42 server systemd[1]: lab10-app.service: Failed with result 'exit-code'.
Jul 01 10:23:42 server systemd[1]: lab10-app.service: Scheduled restart job, restart counter is at 1.
Jul 01 10:23:42 server systemd[1]: lab10-app.service: Start request repeated too quickly.
Jul 01 10:23:42 server systemd[1]: lab10-app.service: Failed with result 'start-limit-hit'.
```

---

## Hints

<details>
<summary>Hint 1</summary>
Status code `203/EXEC` means systemd couldn't execute the binary specified in `ExecStart=`. Check the path carefully — is there a typo? Verify the file exists at that exact path with `ls -la`.
</details>

<details>
<summary>Hint 2</summary>
Multiple issues exist: (1) ExecStart path has a typo (`/usr/loca/` vs `/usr/local/`), (2) `Type=notify` requires the app to call `sd_notify(READY=1)` — change to `Type=simple`, (3) `WorkingDirectory` points to a non-existent directory, (4) `RestartSec=0` with `StartLimitBurst=3` causes immediate rate limiting.
</details>

<details>
<summary>Hint 3</summary>
After fixing the unit file, you must run `systemctl daemon-reload` AND `systemctl reset-failed lab10-app` to clear the start-limit-hit state before trying to start again.
</details>

---

## Fix Commands

```bash
# Identify all issues
systemctl status lab10-app
journalctl -u lab10-app --no-pager
cat /etc/systemd/system/lab10-app.service

# Verify the binary exists at the correct path
ls -la /usr/local/bin/lab10-app

# Fix the service file
sudo vi /etc/systemd/system/lab10-app.service

# Required changes:
# 1. Fix ExecStart: /usr/loca/bin/lab10-app → /usr/local/bin/lab10-app
# 2. Change Type=notify → Type=simple (app doesn't sd_notify)
# 3. Fix or remove WorkingDirectory=/opt/lab10-nonexistent-dir
# 4. Set RestartSec=5 (prevents rate limiting)
# 5. Increase StartLimitBurst=5 or StartLimitIntervalSec=60

# After editing:
sudo systemctl daemon-reload
sudo systemctl reset-failed lab10-app
sudo systemctl start lab10-app
systemctl status lab10-app
```

---

## Cleanup

```bash
sudo bash cleanup.sh
```
