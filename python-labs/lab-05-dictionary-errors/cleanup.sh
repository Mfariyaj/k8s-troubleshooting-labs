#!/bin/bash
# Cleanup Lab 05 - Dictionary Errors

LAB_DIR="/tmp/python-lab-05"

if [ -d "$LAB_DIR" ]; then
    rm -rf "$LAB_DIR"
    echo "🧹 Lab 05 cleaned up: removed $LAB_DIR"
else
    echo "ℹ️  Lab 05 not deployed (nothing to clean)"
fi
