#!/bin/bash
# Cleanup Lab 07 - String Formatting

LAB_DIR="/tmp/python-lab-07"

if [ -d "$LAB_DIR" ]; then
    rm -rf "$LAB_DIR"
    echo "🧹 Lab 07 cleaned up: removed $LAB_DIR"
else
    echo "ℹ️  Lab 07 not deployed (nothing to clean)"
fi
