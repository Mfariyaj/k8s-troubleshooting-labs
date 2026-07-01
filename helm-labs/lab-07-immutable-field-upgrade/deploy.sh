#!/bin/bash
# Lab 07: Immutable Field Upgrade Failure
# This demonstrates the issue with version labels in selector.matchLabels

echo "=== Lab 07: Immutable Field Upgrade ==="
echo ""
echo "This lab requires a live cluster. It demonstrates:"
echo "  1. Install chart v0.1.0 (works fine)"
echo "  2. Upgrade to chart v0.2.0 (FAILS - selector.matchLabels is immutable)"
echo ""
echo "Running: helm template myrelease ./mychart --debug"
echo ""

cd "$(dirname "$0")"
helm template myrelease ./mychart --debug

echo ""
echo "❌ selector.matchLabels includes {{ .Chart.AppVersion }} and {{ .Chart.Version }}"
echo "   These change on every chart upgrade, but selector.matchLabels is IMMUTABLE"
echo "   after a Deployment is created!"
echo ""
echo "Simulated upgrade error:"
echo '  Error: UPGRADE FAILED: cannot patch "myrelease-mychart" with kind Deployment:'
echo '  Deployment.apps "myrelease-mychart" is invalid: spec.selector:'
echo '  Invalid value: ... field is immutable'
