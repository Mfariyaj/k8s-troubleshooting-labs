#!/usr/bin/env python3
"""
Infrastructure Health Checker
==============================
This script checks server health by importing utilities and configuration.

INTENDED BEHAVIOR:
- Import helper functions from utils.py
- Import settings from config.py
- Run health checks on servers
"""

# BUG 1: Importing a module that doesn't exist (typo in name)
import reqeusts

# BUG 2: Circular import — config imports from utils, utils imports from config
from config import SERVER_LIST, TIMEOUT
from utils import check_server_health, format_output


def main():
    """Run health checks on all configured servers."""
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
