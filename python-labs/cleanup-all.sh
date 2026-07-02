#!/bin/bash
# Clean up all Python troubleshooting labs

echo "=========================================="
echo "  Python Troubleshooting Labs - Cleanup"
echo "=========================================="
echo ""

for i in $(seq -w 1 15); do
    lab_dir="/tmp/python-lab-$i"
    if [ -d "$lab_dir" ]; then
        echo "🧹 Removing: $lab_dir"
        rm -rf "$lab_dir"
    fi
done

echo ""
echo "✅ All Python labs cleaned up!"
