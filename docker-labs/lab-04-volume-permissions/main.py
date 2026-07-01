#!/usr/bin/env python3
"""Simple data processing application that writes to a volume."""

import os
import time
import datetime

LOG_PATH = os.environ.get('LOG_PATH', '/app/data/output.log')
DATA_DIR = os.environ.get('DATA_DIR', '/app/data')

print("Starting application...")
print(f"Running as user: {os.getuid()}:{os.getgid()}")
print(f"Writing to {LOG_PATH}")

try:
    # This will fail due to permission denied
    os.makedirs(DATA_DIR, exist_ok=True)
    with open(LOG_PATH, 'w') as f:
        f.write(f"Application started at {datetime.datetime.now()}\n")
    print("✅ Successfully wrote to log file")
except PermissionError as e:
    print(f"❌ PermissionError: [Errno 13] Permission denied: '{LOG_PATH}'")
    print(f"   Current UID: {os.getuid()}, GID: {os.getgid()}")
    print(f"   Directory owner: Check 'ls -la {DATA_DIR}'")
    raise SystemExit(1)

# Keep running and writing periodic data
print("Application running, writing data every 5 seconds...")
counter = 0
while True:
    try:
        with open(os.path.join(DATA_DIR, 'metrics.txt'), 'a') as f:
            f.write(f"metric_{counter}: {datetime.datetime.now()}\n")
        counter += 1
        time.sleep(5)
    except PermissionError:
        print(f"❌ PermissionError writing metrics")
        raise SystemExit(1)
