# Lab 10: Subprocess & OS — Running System Commands Safely

## How to Use This Lab

```bash
./deploy.sh
vim /tmp/python-lab-10/broken_script.py
cd /tmp/python-lab-10 && python3 broken_script.py
cd - && ./cleanup.sh
```

---

## 📚 What This Lab Teaches

**subprocess.run(), Shell Commands, and Security**

DevOps engineers frequently need to run system commands from Python. Key concepts:

- **`subprocess.run()`** — the modern way to run commands. Returns a `CompletedProcess` object.
- **List vs String commands** — `subprocess.run(["ls", "-la"])` (safe) vs `subprocess.run("ls -la", shell=True)` (dangerous)
- **`shell=True` dangers** — if user input goes into the command string, it enables shell injection (like SQL injection but for bash)
- **`check=True`** — raises `CalledProcessError` if the command exits with non-zero. Useful, but be aware that some programs (like `grep`) return non-zero for "no matches"
- **`capture_output=True`** — captures stdout and stderr into the result object
- **`shlex.split()`** — safely splits a command string into a list: `"ls -la /tmp"` → `["ls", "-la", "/tmp"]`

Always prefer passing commands as a list without `shell=True`. Use `shlex.split()` when you have a command string. Never put user input directly into shell commands.

---

## 🔧 Scenario

A system status checker that runs `df`, `ps`, `hostname`, and other commands to produce a status report. The commands need to be run safely and their output parsed.

---

## 💥 Error Output

```
  System Status Report
=======================================================

📊 System Info:
  Hostname: myhost
  Uptime:   up 3 days

💾 Disk Usage (/tmp):
  ⚠️  Could not get disk usage: [Errno 2] No such file or directory: 'df -h /tmp': 'df -h /tmp'
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>

When `shell=False` (the default), the first argument to `subprocess.run()` must be a **list** of strings, not a single string. Python tries to find an executable literally named `"df -h /tmp"` (with spaces in the filename).
</details>

<details>
<summary>Hint 2 (More specific)</summary>

Three bugs:
1. `get_disk_usage()`: Passes a string `"df -h /tmp"` but shell=False requires a list: `["df", "-h", "/tmp"]`
2. `get_running_processes()`: Uses `shell=True` with `check=True` — `grep` returns exit code 1 when no matches found, causing CalledProcessError. Also has shell injection risk.
3. The shell injection in #2: if `search_term` were `"; rm -rf /"` it would execute arbitrary commands
</details>

<details>
<summary>Hint 3 (Almost the answer)</summary>

1. Change to: `subprocess.run(["df", "-h", "/tmp"], capture_output=True, text=True)` or use `shlex.split("df -h /tmp")`
2. Remove `check=True` (grep exit code 1 isn't a real error), or wrap in try/except CalledProcessError
3. Better: rewrite without shell=True: `subprocess.run(["ps", "aux"], ...)` and then filter in Python instead of piping through grep
</details>

---

## 📖 Python Docs Reference

- [subprocess module](https://docs.python.org/3/library/subprocess.html)
- [subprocess.run()](https://docs.python.org/3/library/subprocess.html#subprocess.run)
- [shlex.split()](https://docs.python.org/3/library/shlex.html#shlex.split)
- [Security Considerations](https://docs.python.org/3/library/subprocess.html#security-considerations)

---

## Difficulty: ⭐⭐⭐ Advanced

**Expected time:** 7-10 minutes  
**Bugs to find:** 3 (including a security issue)  
**Concept:** Safe subprocess usage, shell injection prevention
