#!/usr/bin/env python3
"""
DevOps Toolkit — Package Usage Demo
=====================================
This script uses a custom package (mytools) for infrastructure management.

INTENDED BEHAVIOR:
- Import utility functions from the mytools package
- Use them to check infrastructure status
- Demonstrate proper package imports
"""

import sys
import os

# BUG 1: Not adding the src directory to the path when running directly
# The package is in src/mytools/ but Python doesn't know to look there
from mytools import format_bytes, get_system_stats, DevOpsToolkit


def main():
    print("=" * 55)
    print("  DevOps Toolkit Demo")
    print("=" * 55)
    
    # Test format_bytes utility
    print("\n📊 Storage Formatting:")
    sizes = [1024, 1048576, 1073741824, 5368709120]
    for size in sizes:
        print(f"  {size:>15} bytes = {format_bytes(size)}")
    
    # Test system stats
    print("\n💻 System Stats:")
    stats = get_system_stats()
    for key, value in stats.items():
        print(f"  {key}: {value}")
    
    # Test toolkit class
    print("\n🔧 DevOps Toolkit:")
    toolkit = DevOpsToolkit("production")
    toolkit.check_disk()
    toolkit.check_memory()
    toolkit.summary()
    
    print("\n" + "=" * 55)
    print("  ✅ All toolkit functions working!")
    print("=" * 55)


if __name__ == "__main__":
    main()
