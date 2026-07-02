#!/bin/bash
# Cleanup Lab 09 - Class and OOP

LAB_DIR="/tmp/python-lab-09"

if [ -d "$LAB_DIR" ]; then
    rm -rf "$LAB_DIR"
    echo "🧹 Lab 09 cleaned up: removed $LAB_DIR"
else
    echo "ℹ️  Lab 09 not deployed (nothing to clean)"
fi
