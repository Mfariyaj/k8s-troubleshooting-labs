#!/usr/bin/env python3
"""
Retry Decorator + Log Generator
=================================
This script implements a retry decorator for flaky operations
and a generator that processes log files line-by-line.

INTENDED BEHAVIOR:
- Retry decorator that retries failed operations N times
- Generator that yields parsed log entries
- Pipeline: generate logs → filter → transform → output
"""

import time
import random
import functools


# ============================================================
# PART 1: Retry Decorator
# ============================================================

def retry(max_attempts=3, delay=1.0):
    """Decorator that retries a function on failure."""
    def decorator(func):
        # BUG 1: Missing @functools.wraps — the decorated function loses its name and docstring
        def wrapper(*args, **kwargs):
            last_exception = None
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    last_exception = e
                    if attempt < max_attempts - 1:
                        print(f"  ⚠️  {func.__name__} failed (attempt {attempt + 1}/{max_attempts}): {e}")
                        time.sleep(delay * 0.01)  # Short delay for lab
            raise last_exception
        return wrapper
    return decorator


@retry(max_attempts=3, delay=0.5)
def deploy_service(service_name):
    """Deploy a service to the cluster. Sometimes fails transiently."""
    # Simulate flaky deployment
    if random.random() < 0.6:
        raise ConnectionError(f"Failed to reach deployment server for {service_name}")
    return f"{service_name} deployed successfully"


# ============================================================
# PART 2: Log Generator
# ============================================================

def generate_log_lines():
    """Generator that yields log lines one at a time."""
    logs = [
        "2024-01-15 10:00:01 INFO  Starting application...",
        "2024-01-15 10:00:02 INFO  Loading configuration from /etc/app/config.yaml",
        "2024-01-15 10:00:03 WARN  Cache connection slow (2.3s latency)",
        "2024-01-15 10:00:04 ERROR Failed to connect to payment-gateway: timeout",
        "2024-01-15 10:00:05 INFO  Retry succeeded for payment-gateway",
        "2024-01-15 10:00:06 INFO  Server ready on port 8080",
        "2024-01-15 10:00:10 ERROR Out of memory in worker-3: killed",
        "2024-01-15 10:00:11 WARN  High CPU usage detected (95%)",
        "2024-01-15 10:00:12 INFO  Auto-scaling triggered: +2 pods",
    ]
    
    for line in logs:
        yield line


def parse_log_entry(line):
    """Parse a single log line into components."""
    parts = line.split(None, 3)
    if len(parts) >= 4:
        return {
            "date": parts[0],
            "time": parts[1],
            "level": parts[2],
            "message": parts[3]
        }
    return None


def filter_errors(log_generator):
    """Filter generator to only yield ERROR and WARN entries."""
    # BUG 2: Generator exhaustion — if you call this twice on the same generator,
    # the second call gets nothing
    for entry in log_generator:
        parsed = parse_log_entry(entry)
        if parsed and parsed["level"] in ("ERROR", "WARN"):
            yield parsed


def process_logs():
    """Process logs using generator pipeline."""
    # BUG 3: Using the same generator object twice — second iteration is empty!
    log_gen = generate_log_lines()
    
    # First pass: count all entries
    all_entries = list(log_gen)
    total_count = len(all_entries)
    
    # Second pass: filter errors (but log_gen is already exhausted!)
    error_entries = list(filter_errors(log_gen))
    
    return total_count, error_entries


# ============================================================
# MAIN
# ============================================================

def main():
    random.seed(42)
    
    print("=" * 55)
    print("  DevOps Automation: Retry + Log Processing")
    print("=" * 55)
    
    # Part 1: Test retry decorator
    print("\n🔄 Testing retry decorator:")
    services = ["auth-service", "payment-service", "user-service"]
    
    for service in services:
        try:
            result = deploy_service(service)
            print(f"  ✅ {result}")
        except ConnectionError as e:
            print(f"  ❌ {service}: All retries failed — {e}")
    
    # Check that decorator preserves function metadata
    print(f"\n📋 Function metadata check:")
    print(f"  Function name: {deploy_service.__name__}")
    print(f"  Function doc: {deploy_service.__doc__}")
    
    if deploy_service.__name__ == "wrapper":
        print("  ⚠️  BUG: Function name is 'wrapper' — @functools.wraps is missing!")
    
    # Part 2: Test log generator
    print("\n📊 Log Processing:")
    total, errors = process_logs()
    
    print(f"  Total log entries: {total}")
    print(f"  Error/Warning entries: {len(errors)}")
    
    if len(errors) == 0:
        print("  ⚠️  BUG: Got 0 errors — generator was exhausted before second pass!")
    
    for entry in errors:
        icon = "🔴" if entry["level"] == "ERROR" else "🟡"
        print(f"  {icon} [{entry['level']}] {entry['message']}")
    
    print("\n" + "=" * 55)


if __name__ == "__main__":
    main()
