#!/bin/bash
# Lab 08: Schema Validation Failures
# This demonstrates overly restrictive schema constraints

echo "=== Lab 08: Schema Validation Failures ==="
echo ""
echo "Running: helm template myrelease ./mychart --debug"
echo ""

cd "$(dirname "$0")"
helm template myrelease ./mychart --debug

echo ""
echo "❌ Schema validation rejects valid values:"
echo "   - replicaCount: 2 is not in enum [1, 3, 5]"
echo "   - image.tag: '1.23' is a string but schema expects number"
