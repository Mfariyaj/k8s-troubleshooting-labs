#!/bin/bash
# Cleanup Lab 12 - YAML/JSON Parsing

LAB_DIR="/tmp/python-lab-12"

if [ -d "$LAB_DIR" ]; then
    rm -rf "$LAB_DIR"
    echo "🧹 Lab 12 cleaned up: removed $LAB_DIR"
else
    echo "ℹ️  Lab 12 not deployed (nothing to clean)"
fi
