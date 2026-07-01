# Lab 05: File Permissions

## Difficulty: 🟢 Easy

## Scenario

A new application was deployed to `/opt/lab05-app/` and should run as the `appuser` service account. The application fails to start with "Permission denied" errors. The deployment team tested it as root and it worked, but the service account can't run it.

---

## What You'll See

### `sudo -u appuser bash /opt/lab05-app/app.sh`
```
[myapp] Starting application...
[myapp] Reading configuration from /opt/lab05-app/config.conf
[myapp] ERROR: Cannot read configuration file: /opt/lab05-app/config.conf
[myapp] Permission denied!
```

### `ls -la /opt/lab05-app/`
```
total 16
drwxr-xr-x 3 root root 4096 Jul  1 10:00 .
drwxr-xr-x 5 root root 4096 Jul  1 10:00 ..
-rw-r--r-- 1 root root  512 Jul  1 10:00 app.sh
---------- 1 root root  380 Jul  1 10:00 config.conf
drwx------ 2 root root 4096 Jul  1 10:00 logs
```

### `stat /opt/lab05-app/config.conf`
```
  File: /opt/lab05-app/config.conf
  Size: 380       Blocks: 8    IO Block: 4096   regular file
Access: (0000/----------)  Uid: (    0/    root)   Gid: (    0/    root)
```

---

## Hints

<details>
<summary>Hint 1</summary>
Check file permissions with `ls -la` and ownership with `stat`. Look for files with `0000` permissions or wrong ownership. Remember the app runs as `appuser`, not root.
</details>

<details>
<summary>Hint 2</summary>
There are multiple issues: the config file has no permissions (`----------`), the logs directory is only accessible by root (`drwx------`), and the app.sh script may not be executable.
</details>

<details>
<summary>Hint 3</summary>
Fix ownership: `chown appuser:appuser /opt/lab05-app/config.conf`. Fix permissions: `chmod 640` for config (readable by owner), `chmod 755` for logs directory, `chmod 750` for app.sh.
</details>

---

## Fix Commands

```bash
# View current permissions
ls -la /opt/lab05-app/

# Fix config file: readable by appuser
sudo chown appuser:appuser /opt/lab05-app/config.conf
sudo chmod 640 /opt/lab05-app/config.conf

# Fix log directory: writable by appuser
sudo chown appuser:appuser /opt/lab05-app/logs
sudo chmod 755 /opt/lab05-app/logs

# Fix app script: make executable
sudo chmod 750 /opt/lab05-app/app.sh
sudo chown appuser:appuser /opt/lab05-app/app.sh

# Verify the fix
sudo -u appuser bash /opt/lab05-app/app.sh
```

---

## Cleanup

```bash
sudo bash cleanup.sh
```
