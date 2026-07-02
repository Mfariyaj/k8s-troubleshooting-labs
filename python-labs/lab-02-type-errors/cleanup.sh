#!/bin/bash
# Cleanup Lab 02 - Type Errors

LAB_DIR="/tmp/python-lab-02"

if [ -d "$LAB_DIR" ]; then
    rm -rf "$LAB_DIR"
    echo "🧹 Lab 02 cleaned up: removed $LAB_DIR"
else
    echo "ℹ️  Lab 02 not deployed (nothing to clean)"
fi
