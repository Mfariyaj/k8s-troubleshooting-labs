#!/bin/bash
# Lab 02: Template Function Errors
# This demonstrates indent vs nindent and scope issues in range

echo "=== Lab 02: Template Function Errors ==="
echo ""
echo "Running: helm template myrelease ./mychart --debug"
echo ""

cd "$(dirname "$0")"
helm template myrelease ./mychart --debug

echo ""
echo "❌ Look for YAML indentation errors and nil values inside range blocks"
echo "   Issues: indent vs nindent, and .Values scope inside range"
