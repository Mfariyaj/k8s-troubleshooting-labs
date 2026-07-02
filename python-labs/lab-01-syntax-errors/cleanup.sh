#!/bin/bash
# Cleanup Lab 01 - Syntax Errors

LAB_DIR="/tmp/python-lab-01"

if [ -d "$LAB_DIR" ]; then
    rm -rf "$LAB_DIR"
    echo "🧹 Lab 01 cleaned up: removed $LAB_DIR"
else
    echo "ℹ️  Lab 01 not deployed (nothing to clean)"
fi
