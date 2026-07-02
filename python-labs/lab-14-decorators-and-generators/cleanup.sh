#!/bin/bash
# Cleanup Lab 14 - Decorators and Generators

LAB_DIR="/tmp/python-lab-14"

if [ -d "$LAB_DIR" ]; then
    rm -rf "$LAB_DIR"
    echo "🧹 Lab 14 cleaned up: removed $LAB_DIR"
else
    echo "ℹ️  Lab 14 not deployed (nothing to clean)"
fi
