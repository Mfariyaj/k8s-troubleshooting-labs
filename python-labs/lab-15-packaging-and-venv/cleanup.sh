#!/bin/bash
# Cleanup Lab 15 - Packaging and Venv

LAB_DIR="/tmp/python-lab-15"

if [ -d "$LAB_DIR" ]; then
    rm -rf "$LAB_DIR"
    echo "🧹 Lab 15 cleaned up: removed $LAB_DIR"
else
    echo "ℹ️  Lab 15 not deployed (nothing to clean)"
fi
