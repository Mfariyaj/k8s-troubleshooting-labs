# Solution: Lab 10 — Subprocess and OS

## Root Cause

### Bug 1: String command without shell=True
```python
# BROKEN: string + shell=False (default) — Python looks for file named "df -h /tmp"
result = subprocess.run("df -h /tmp", capture_output=True, text=True)

# FIXED: Pass as a list
result = subprocess.run(["df", "-h", "/tmp"], capture_output=True, text=True)
```

### Bug 2: check=True with grep (exit code 1 = no match)
```python
# BROKEN: grep returns exit code 1 when no match — check=True raises exception
cmd = f"ps aux | grep {search_term} | grep -v grep"
result = subprocess.run(cmd, shell=True, check=True, capture_output=True, text=True)

# FIXED: Don't use check=True with grep, or better, avoid shell=True entirely
result = subprocess.run(["ps", "aux"], capture_output=True, text=True)
lines = [l for l in result.stdout.split('\n') if search_term in l and 'grep' not in l]
return '\n'.join(lines)
```

### Bug 3: Shell injection vulnerability
```python
# BROKEN: User input directly in shell command — shell injection possible
cmd = f"ps aux | grep {search_term}"

# FIXED: Use Python filtering instead of shell piping
# Never put user input into shell=True commands
```

---

## Fixed Code

```python
def get_disk_usage():
    result = subprocess.run(
        ["df", "-h", "/tmp"],
        capture_output=True,
        text=True
    )
    return result.stdout


def get_running_processes(search_term):
    # Safe: no shell=True, no user input in commands
    result = subprocess.run(
        ["ps", "aux"],
        capture_output=True,
        text=True
    )
    # Filter in Python — safe from injection
    lines = [
        line for line in result.stdout.split('\n')
        if search_term.lower() in line.lower() and 'grep' not in line
    ]
    return '\n'.join(lines)
```

---

## Key Takeaways

1. **Without `shell=True`, pass commands as a list** — `["cmd", "arg1", "arg2"]`
2. **Avoid `shell=True`** — it opens shell injection vulnerabilities
3. **`check=True` treats non-zero exit as error** — some programs use non-zero for non-error conditions
4. **Use `shlex.split()`** to convert a command string to a list safely
5. **Filter in Python** instead of piping through shell commands (grep, awk, sed)
