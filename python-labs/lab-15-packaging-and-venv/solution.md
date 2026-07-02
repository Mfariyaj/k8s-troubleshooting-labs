# Solution: Lab 15 — Packaging and Venv

## Root Cause

### Bug 1: Import path not set up for direct execution
```python
# BROKEN: Python can't find mytools because it's in src/
from mytools import format_bytes, get_system_stats, DevOpsToolkit

# FIXED: Add the src directory to sys.path for direct execution
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "src"))
from mytools import format_bytes, get_system_stats, DevOpsToolkit
```

Alternatively, install the package with `pip install -e .` (editable mode) and fix setup.py.

### Bug 2: __init__.py imports from non-existent submodules
```python
# BROKEN: These submodules don't exist
from mytools.helpers import format_bytes
from mytools.system import get_system_stats

# FIXED: The functions are defined directly in __init__.py
# Just remove these import lines — functions are already in __init__.py
```

### Bug 3: Class name case mismatch
```python
# BROKEN: Class defined as DevopsToolkit (lowercase 'o')
class DevopsToolkit:

# But imported as DevOpsToolkit (capital 'O')
from mytools import DevOpsToolkit

# FIXED: Make them match — either change the class or the import
class DevOpsToolkit:  # Match what broken_script.py expects
```

### Setup.py/pyproject.toml fix:
```python
# FIXED setup.py:
package_dir={"": "src"},  # Source is in 'src'
packages=find_packages(where="src"),
```

```toml
# FIXED pyproject.toml:
[tool.setuptools.packages.find]
where = ["src"]
```

---

## Fixed __init__.py

```python
"""
MyTools — DevOps Utility Package
"""

def format_bytes(size_bytes):
    """Convert bytes to human-readable format."""
    if size_bytes == 0:
        return "0B"
    units = ["B", "KB", "MB", "GB", "TB"]
    unit_index = 0
    size = float(size_bytes)
    while size >= 1024 and unit_index < len(units) - 1:
        size /= 1024
        unit_index += 1
    return f"{size:.1f} {units[unit_index]}"


def get_system_stats():
    """Get basic system statistics."""
    import platform
    import os
    return {
        "hostname": platform.node(),
        "os": platform.system(),
        "python_version": platform.python_version(),
        "cpu_count": os.cpu_count(),
        "pid": os.getpid(),
    }


class DevOpsToolkit:
    """Main toolkit class for infrastructure operations."""
    def __init__(self, environment):
        self.environment = environment
        self.checks_passed = 0
        self.checks_failed = 0
    
    def check_disk(self):
        import shutil
        total, used, free = shutil.disk_usage("/tmp")
        usage_pct = (used / total) * 100
        status = "OK" if usage_pct < 90 else "WARNING"
        print(f"  💾 Disk: {format_bytes(used)}/{format_bytes(total)} ({usage_pct:.1f}%) [{status}]")
        if status == "OK":
            self.checks_passed += 1
        else:
            self.checks_failed += 1
    
    def check_memory(self):
        print(f"  🧠 Memory: 4.2GB/16.0GB (26.3%) [OK]")
        self.checks_passed += 1
    
    def summary(self):
        total = self.checks_passed + self.checks_failed
        print(f"  📋 Environment: {self.environment}")
        print(f"  📋 Results: {self.checks_passed}/{total} checks passed")
```

---

## Key Takeaways

1. **`sys.path.insert(0, "src")`** for direct execution without installation
2. **`pip install -e .`** (editable mode) is the proper way to develop packages
3. **`__init__.py`** defines what a package exports — import errors here cascade to all users
4. **setup.py/pyproject.toml `where`** must point to the actual source directory
5. **Python is case-sensitive** — `DevopsToolkit` ≠ `DevOpsToolkit`
