#!/bin/bash
# Cleanup Lab 10 - Subprocess and OS

LAB_DIR="/tmp/python-lab-10"

if [ -d "$LAB_DIR" ]; then
    rm -rf "$LAB_DIR"
    echo "🧹 Lab 10 cleaned up: removed $LAB_DIR"
else
    echo "ℹ️  Lab 10 not deployed (nothing to clean)"
fi
