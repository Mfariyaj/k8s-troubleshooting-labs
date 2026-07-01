#!/bin/bash
# Lab 14: Cleanup

echo "Cleaning up Lab 14: Fact Caching Poisoned..."

rm -rf /tmp/ansible-lab14

# Flush Redis fact cache
if command -v redis-cli &> /dev/null; then
    echo "Flushing Redis fact cache..."
    redis-cli FLUSHDB 2>/dev/null || true
fi

echo "Cleanup complete."
