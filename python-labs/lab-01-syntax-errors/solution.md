# Solution: Lab 01 — Syntax Errors

## Root Cause

The script has 3 syntax errors that prevent Python from running it:

### Bug 1: Missing colon after function definition (Line 18)
```python
# BROKEN:
def read_config(filepath)

# FIXED:
def read_config(filepath):
```
**Why:** Python requires a colon `:` at the end of any compound statement (`def`, `if`, `for`, `while`, `class`, `with`). The colon tells Python "a new indented block follows."

### Bug 2: Wrong indentation (Line 49)
```python
# BROKEN (not indented inside the for loop):
    for key, value in config.items():
if key.startswith("server"):

# FIXED (properly indented):
    for key, value in config.items():
        if key.startswith("server"):
```
**Why:** Python uses indentation to determine code structure. The `if` statement is part of the `for` loop body, so it must be indented one level deeper (8 spaces total, since it's inside a function + for loop).

### Bug 3: Mismatched quotes (Line 95)
```python
# BROKEN (starts with single quote, ends with double quote):
            print('\n❌ Configuration has issues!")

# FIXED (matching quotes):
            print('\n❌ Configuration has issues!')
```
**Why:** Python strings must start and end with the same quote character. You can use either `'...'` or `"..."`, but they must match.

---

## Fixed Code

```python
#!/usr/bin/env python3
"""
DevOps Config File Reader
"""

import os
import sys

def read_config(filepath):  # FIX 1: Added colon
    """Read configuration file and return as dictionary."""
    config = {}
    
    if not os.path.exists(filepath):
        print(f"Error: Config file {filepath} not found")
        return config
    
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    for line in lines:
        if line.startswith('#') or line.strip() == '':
            continue
        if '=' in line:
            key, value = line.strip().split('=', 1)
            config[key.strip()] = value.strip()
    
    return config


def display_config(config):
    """Display configuration in a formatted way."""
    print("=" * 50)
    print("  Server Configuration Summary")
    print("=" * 50)
    
    for key, value in config.items():
        if key.startswith("server"):  # FIX 2: Proper indentation
            print(f"  🖥️  {key}: {value}")
        elif key.startswith("db"):
            print(f"  💾 {key}: {value}")
        else:
            print(f"  ⚙️  {key}: {value}")
    
    print("=" * 50)
    print(f"  Total settings: {len(config)}")
    print("=" * 50)


def validate_config(config):
    """Validate required configuration keys exist."""
    required_keys = ['server_host', 'server_port', 'db_host']
    missing = []
    for key in required_keys:
        if key not in config:
            missing.append(key)
    if missing:
        print(f"Warning: Missing required keys: {missing}")
        return False
    return True


def main():
    sample_config = """# Server Configuration
server_host=10.0.1.50
server_port=8080
server_name=web-prod-01
db_host=10.0.2.100
db_port=5432
db_name=appdb
log_level=INFO
max_connections=100
"""
    config_path = '/tmp/server.conf'
    with open(config_path, 'w') as f:
        f.write(sample_config)
    
    print("Reading server configuration...")
    config = read_config(config_path)
    
    if config:
        display_config(config)
        is_valid = validate_config(config)
        if is_valid:
            print("\n✅ Configuration is valid!")
        else:
            print('\n❌ Configuration has issues!')  # FIX 3: Matching quotes
    else:
        print("❌ Failed to read configuration")


if __name__ == "__main__":
    main()
```

---

## Verification

```bash
$ python3 broken_script.py
Reading server configuration...
==================================================
  Server Configuration Summary
==================================================
  🖥️  server_host: 10.0.1.50
  🖥️  server_port: 8080
  🖥️  server_name: web-prod-01
  💾 db_host: 10.0.2.100
  💾 db_port: 5432
  💾 db_name: appdb
  ⚙️  log_level: INFO
  ⚙️  max_connections: 100
==================================================
  Total settings: 8
==================================================

✅ Configuration is valid!
```

---

## Key Takeaways

1. **Colons are mandatory** after `def`, `if`, `for`, `while`, `class`, `with`, `elif`, `else`, `try`, `except`, `finally`
2. **Indentation defines structure** — use 4 spaces consistently (never mix tabs and spaces)
3. **Quotes must match** — start and end with the same quote character
4. **SyntaxError stops all execution** — Python won't run any code until all syntax is correct
5. **The line number in the error** may point to the line *after* the actual problem
