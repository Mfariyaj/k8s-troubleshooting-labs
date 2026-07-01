#!/bin/bash
# Lab 04: Hook Weight Ordering
# This demonstrates incorrect hook weight causing job to run before secret is created

echo "=== Lab 04: Hook Weight Ordering ==="
echo ""
echo "Running: helm install myrelease ./mychart --dry-run --debug"
echo ""

cd "$(dirname "$0")"
helm install myrelease ./mychart --dry-run --debug

echo ""
echo "❌ The Job (weight:5) runs BEFORE the Secret (weight:10) is created."
echo "   The Job needs the Secret but it doesn't exist yet!"
echo "   Lower weight = executed first. The Secret must have a lower weight than the Job."
