#!/bin/bash
# Cleanup Lab 13 - Async and Threading

LAB_DIR="/tmp/python-lab-13"

if [ -d "$LAB_DIR" ]; then
    rm -rf "$LAB_DIR"
    echo "🧹 Lab 13 cleaned up: removed $LAB_DIR"
else
    echo "ℹ️  Lab 13 not deployed (nothing to clean)"
fi
