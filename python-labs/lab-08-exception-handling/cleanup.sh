#!/bin/bash
# Cleanup Lab 08 - Exception Handling

LAB_DIR="/tmp/python-lab-08"

if [ -d "$LAB_DIR" ]; then
    rm -rf "$LAB_DIR"
    echo "🧹 Lab 08 cleaned up: removed $LAB_DIR"
else
    echo "ℹ️  Lab 08 not deployed (nothing to clean)"
fi
