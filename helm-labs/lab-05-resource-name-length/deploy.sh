#!/bin/bash
# Lab 05: Resource Name Length Exceeds 63 Characters
# This demonstrates the DNS label limit issue with long chart names

echo "=== Lab 05: Resource Name Length Exceeds 63 Characters ==="
echo ""
echo "Running: helm template my-production-release ./mychart --debug"
echo ""

cd "$(dirname "$0")"
helm template my-production-release ./mychart --debug

echo ""
NAME="my-production-release-my-super-long-application-chart-name-that-exceeds-kubernetes-limits"
echo "Generated name: $NAME"
echo "Name length: $(echo -n "$NAME" | wc -c) characters (max allowed: 63)"
echo ""
echo "❌ Resource name exceeds Kubernetes' 63-character DNS label limit!"
