#!/bin/bash
# Lab 03: Dependency Download Failure
# This demonstrates broken dependency repository URL and version

echo "=== Lab 03: Dependency Download Failure ==="
echo ""
echo "Running: helm dependency update ./mychart"
echo ""

cd "$(dirname "$0")"
helm dependency update ./mychart

echo ""
echo "Running: helm dependency build ./mychart"
echo ""
helm dependency build ./mychart

echo ""
echo "❌ Dependency download fails due to typo in repository URL and non-existent version"
