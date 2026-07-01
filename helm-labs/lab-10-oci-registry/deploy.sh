#!/bin/bash
# Lab 10: OCI Registry Push Failures
# This demonstrates wrong OCI URL and missing registry login

echo "=== Lab 10: OCI Registry Push Failures ==="
echo ""
echo "Running: helm package ./mychart"
echo ""

cd "$(dirname "$0")"
helm package ./mychart

echo ""
echo "Running: helm push mychart-0.1.0.tgz oci://wrong-registry.io/charts"
echo ""
helm push mychart-0.1.0.tgz oci://wrong-registry.io/charts

echo ""
echo "❌ Push fails because:"
echo "   1. The OCI registry URL 'wrong-registry.io' doesn't exist"
echo "   2. No 'helm registry login' was performed first"
echo "   Run './push-chart.sh' to see the full push workflow failure"
