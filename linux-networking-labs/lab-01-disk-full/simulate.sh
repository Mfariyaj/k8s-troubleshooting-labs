#!/bin/bash
# Helper script that opens large files, then deletes them while keeping the fd open
# This simulates the classic "deleted but still open" disk space issue

MARKER="/tmp/.lab01-simulate-running"
touch "$MARKER"

# Create and open a large file, keep it open via file descriptor
exec 3>/tmp/lab01-deleted-openfile.dat
dd if=/dev/zero bs=1M count=200 >&3 2>/dev/null

# Delete the file - space is NOT freed because fd 3 is still open
rm -f /tmp/lab01-deleted-openfile.dat

# Also open another file via tail
dd if=/dev/zero of=/tmp/lab01-hidden-log.dat bs=1M count=150 2>/dev/null
tail -f /tmp/lab01-hidden-log.dat > /dev/null 2>&1 &
TAIL_PID=$!
rm -f /tmp/lab01-hidden-log.dat

echo "$TAIL_PID" > /tmp/.lab01-tail-pid

# Keep this process alive to maintain the open file descriptor
while [ -f "$MARKER" ]; do
    sleep 5
done

# Cleanup fd
exec 3>&-
kill "$TAIL_PID" 2>/dev/null
