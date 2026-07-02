#!/bin/bash
# Cleanup Lab 06 - List Operations

LAB_DIR="/tmp/python-lab-06"

if [ -d "$LAB_DIR" ]; then
    rm -rf "$LAB_DIR"
    echo "🧹 Lab 06 cleaned up: removed $LAB_DIR"
else
    echo "ℹ️  Lab 06 not deployed (nothing to clean)"
fi
