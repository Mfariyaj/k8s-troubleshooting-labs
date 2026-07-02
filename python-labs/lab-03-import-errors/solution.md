# Solution: Lab 03 — Import Errors

## Root Cause

Three import-related bugs across the files:

### Bug 1: Typo in module name (broken_script.py line 14)
```python
# BROKEN:
import reqeusts

# FIXED: Remove it — the script doesn't use requests
# (Or fix to: import requests — but it's unused here)
```

### Bug 2 & 3: Circular import (config.py ↔ utils.py)

`config.py` imports from `utils.py`, and `utils.py` imports from `config.py`. Python can't resolve this cycle.

**Fix for utils.py:** Remove the unnecessary import of SERVER_LIST
```python
# BROKEN:
from config import SERVER_LIST  # Not used in this file!

# FIXED: Remove this line entirely
```

**Fix for config.py:** Define TIMEOUT directly instead of importing from utils
```python
# BROKEN:
from utils import DEFAULT_TIMEOUT
TIMEOUT = DEFAULT_TIMEOUT

# FIXED:
TIMEOUT = 5
```

---

## Fixed Files

**broken_script.py:**
```python
#!/usr/bin/env python3
from config import SERVER_LIST, TIMEOUT
from utils import check_server_health, format_output

def main():
    print("=" * 50)
    print("  Infrastructure Health Check")
    print("=" * 50)
    results = []
    for server in SERVER_LIST:
        status = check_server_health(server, TIMEOUT)
        results.append(status)
    output = format_output(results)
    print(output)
    healthy = sum(1 for r in results if r["status"] == "healthy")
    print(f"\n  Summary: {healthy}/{len(results)} servers healthy")
    print("=" * 50)

if __name__ == "__main__":
    main()
```

**config.py:**
```python
SERVER_LIST = [
    {"host": "web-01.prod.internal", "port": 8080, "name": "Web Server 1"},
    {"host": "web-02.prod.internal", "port": 8080, "name": "Web Server 2"},
    {"host": "api-01.prod.internal", "port": 3000, "name": "API Server"},
    {"host": "db-01.prod.internal", "port": 5432, "name": "Database"},
]
TIMEOUT = 5
```

**utils.py:**
```python
DEFAULT_TIMEOUT = 5

def check_server_health(server, timeout):
    import random
    random.seed(hash(server["host"]))
    is_healthy = random.random() > 0.3
    return {
        "name": server["name"],
        "host": server["host"],
        "port": server["port"],
        "status": "healthy" if is_healthy else "unhealthy",
        "response_time": round(random.uniform(0.01, 2.0), 3) if is_healthy else None
    }

def format_output(results):
    lines = []
    for r in results:
        if r["status"] == "healthy":
            lines.append(f"  ✅ {r['name']} ({r['host']}:{r['port']}) — {r['response_time']}s")
        else:
            lines.append(f"  ❌ {r['name']} ({r['host']}:{r['port']}) — UNREACHABLE")
    return "\n".join(lines)
```

---

## Key Takeaways

1. **Check module name spelling** — `requests` not `reqeusts`
2. **Circular imports are a design problem** — restructure your code
3. **Move shared constants** to a dedicated config file with no imports
4. **Only import what you need** — unused imports cause problems and clutter
5. **requirements.txt typos** will cause `pip install` failures
