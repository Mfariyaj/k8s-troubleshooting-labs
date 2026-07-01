#!/usr/bin/env python3
"""
Memory hog process that simulates a memory leak.
Continuously allocates memory until killed by OOM killer or limit reached.
Uses cgroups memory limit for safety if available.
"""

import sys
import os
import time
import signal

# Safety limit: default 512MB max (prevents actual OOM on host)
MAX_MB = int(os.environ.get('LAB06_MAX_MB', '512'))
CHUNK_SIZE_MB = 10
SLEEP_BETWEEN = 0.5  # seconds between allocations

data = []

def signal_handler(sig, frame):
    print(f"[memory-hog] Received signal {sig}, exiting.")
    sys.exit(0)

signal.signal(signal.SIGTERM, signal_handler)
signal.signal(signal.SIGINT, signal_handler)

print(f"[memory-hog] PID: {os.getpid()}")
print(f"[memory-hog] Starting memory leak simulation...")
print(f"[memory-hog] Safety limit: {MAX_MB}MB")
print(f"[memory-hog] Allocating {CHUNK_SIZE_MB}MB every {SLEEP_BETWEEN}s")
sys.stdout.flush()

allocated = 0

try:
    while allocated < MAX_MB:
        # Allocate a chunk of memory (actual RSS, not just virtual)
        chunk = bytearray(CHUNK_SIZE_MB * 1024 * 1024)
        data.append(chunk)
        allocated += CHUNK_SIZE_MB
        
        print(f"[memory-hog] Allocated: {allocated}MB / {MAX_MB}MB limit")
        sys.stdout.flush()
        time.sleep(SLEEP_BETWEEN)
    
    print(f"[memory-hog] Reached safety limit of {MAX_MB}MB. Holding memory...")
    sys.stdout.flush()
    
    # Hold the memory until killed
    while True:
        time.sleep(5)

except MemoryError:
    print("[memory-hog] MemoryError! System ran out of memory.")
    sys.exit(137)
except KeyboardInterrupt:
    print("[memory-hog] Interrupted.")
    sys.exit(0)
