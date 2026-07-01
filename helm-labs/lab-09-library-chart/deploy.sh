#!/bin/bash
# Lab 09: Library Chart Template Reference Error
# This demonstrates wrong template name when using library charts

echo "=== Lab 09: Library Chart Template Reference ==="
echo ""
echo "Step 1: Building dependencies..."
echo ""

cd "$(dirname "$0")"
helm dependency update ./mychart 2>&1

echo ""
echo "Step 2: Running helm template..."
echo ""
helm template myrelease ./mychart --debug

echo ""
echo "❌ Template fails because 'mylib.deploy' does not exist."
echo "   The correct template name is 'mylib.deployment'"
