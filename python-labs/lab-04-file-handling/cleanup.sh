#!/bin/bash
# Cleanup Lab 04 - File Handling

LAB_DIR="/tmp/python-lab-04"

if [ -d "$LAB_DIR" ]; then
    rm -rf "$LAB_DIR"
    echo "🧹 Lab 04 cleaned up: removed $LAB_DIR"
else
    echo "ℹ️  Lab 04 not deployed (nothing to clean)"
fi

# Also clean up output files
rm -rf /tmp/python-lab-04-output
rm -f /tmp/python-lab-04-input.conf
