# Solution: Lab 04 — File Handling

## Root Cause

### Bug 1: Wrong file path in read_config()
```python
# BROKEN: Ignores filepath param, uses hardcoded nonexistent path
f = open("/etc/nonexistent/app.conf", 'r')

# FIXED: Use the filepath parameter with context manager
with open(filepath, 'r') as f:
    content = f.read()
```

### Bug 2: Missing directory creation in write_config()
```python
# BROKEN: Tries to write to /tmp/python-lab-04-output/ but dir doesn't exist
f = open(output_path, 'w')

# FIXED: Create the directory first, use context manager
os.makedirs(output_dir, exist_ok=True)
with open(output_path, 'w') as f:
    f.write("# Updated Configuration\n")
    for key, value in config.items():
        f.write(f"{key}={value}\n")
```

### Bug 3: Wrong encoding in verify_config()
```python
# BROKEN: File was written as UTF-8 (default), reading as UTF-16
with open(filepath, 'r', encoding='utf-16') as f:

# FIXED: Use matching encoding
with open(filepath, 'r', encoding='utf-8') as f:
```

---

## Fixed Code

```python
def read_config(filepath):
    config = {}
    with open(filepath, 'r') as f:
        content = f.read()
    for line in content.split('\n'):
        if '=' in line and not line.startswith('#'):
            key, value = line.strip().split('=', 1)
            config[key.strip()] = value.strip()
    return config


def write_config(filepath, config):
    output_dir = "/tmp/python-lab-04-output"
    output_path = os.path.join(output_dir, "updated.conf")
    os.makedirs(output_dir, exist_ok=True)
    with open(output_path, 'w') as f:
        f.write("# Updated Configuration\n")
        for key, value in config.items():
            f.write(f"{key}={value}\n")


def verify_config(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    print("Verification - file contents:")
    print(content)
    return content
```

---

## Key Takeaways

1. **Always use `with open(...) as f:`** — it handles closing automatically
2. **Use the function's parameters** — don't hardcode paths
3. **Create directories with `os.makedirs(path, exist_ok=True)`** before writing
4. **Match encoding** — if you write UTF-8, read UTF-8
5. **Default encoding is platform-dependent** — always specify `encoding='utf-8'` explicitly
