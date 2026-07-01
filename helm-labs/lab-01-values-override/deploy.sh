#!/bin/bash
# Lab 01: Values Override Precedence
# This demonstrates the values precedence issue

echo "=== Lab 01: Values Override Precedence ==="
echo ""
echo "Running: helm template myrelease ./mychart -f custom-values.yaml --set replicaCount=5 --debug"
echo ""

cd "$(dirname "$0")"
helm template myrelease ./mychart -f custom-values.yaml --set replicaCount=5 --debug

echo ""
echo "❌ Notice: replicas is 5 (from --set) instead of 3 (from custom-values.yaml)"
echo "   --set always overrides -f values files!"
