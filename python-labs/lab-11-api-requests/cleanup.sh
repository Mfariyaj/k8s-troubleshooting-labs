#!/bin/bash
# Cleanup Lab 11 - API Requests

LAB_DIR="/tmp/python-lab-11"

if [ -d "$LAB_DIR" ]; then
    rm -rf "$LAB_DIR"
    echo "🧹 Lab 11 cleaned up: removed $LAB_DIR"
else
    echo "ℹ️  Lab 11 not deployed (nothing to clean)"
fi
