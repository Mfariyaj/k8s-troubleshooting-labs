#!/bin/bash
# Cleanup Lab 03 - Import Errors

LAB_DIR="/tmp/python-lab-03"

if [ -d "$LAB_DIR" ]; then
    rm -rf "$LAB_DIR"
    echo "🧹 Lab 03 cleaned up: removed $LAB_DIR"
else
    echo "ℹ️  Lab 03 not deployed (nothing to clean)"
fi
