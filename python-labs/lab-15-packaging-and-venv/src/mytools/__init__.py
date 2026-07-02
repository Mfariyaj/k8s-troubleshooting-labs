"""
MyTools — DevOps Utility Package
"""

# BUG 2: Importing from wrong module name (circular or misspelled)
from mytools.helpers import format_bytes
from mytools.system import get_system_stats

# BUG 3: Class name doesn't match what's imported in broken_script.py
class DevopsToolkit:
    """Main toolkit class for infrastructure operations."""
    
    def __init__(self, environment):
        self.environment = environment
        self.checks_passed = 0
        self.checks_failed = 0
    
    def check_disk(self):
        """Check disk usage."""
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
        """Check memory (simulated)."""
        # Simulated memory check
        print(f"  🧠 Memory: 4.2GB/16.0GB (26.3%) [OK]")
        self.checks_passed += 1
    
    def summary(self):
        """Print check summary."""
        total = self.checks_passed + self.checks_failed
        print(f"  📋 Environment: {self.environment}")
        print(f"  📋 Results: {self.checks_passed}/{total} checks passed")


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
