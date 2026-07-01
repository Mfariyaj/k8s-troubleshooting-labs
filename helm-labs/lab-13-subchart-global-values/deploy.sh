#!/bin/bash
set -e

echo "============================================"
echo "Lab 13: Subchart Global Values Propagation"
echo "============================================"
echo ""

cd "$(dirname "$0")"

echo "Step 1: Building dependencies..."
helm dependency build ./parentchart

echo ""
echo "Step 2: Templating to verify values..."
helm template myrelease ./parentchart --debug

echo ""
echo "Step 3: Installing parent chart..."
helm install myrelease ./parentchart \
  --namespace lab13-subcharts \
  --create-namespace

echo ""
echo "If you see errors above, your task is to fix the subchart/global values issues!"
echo ""
echo "Expected outcome:"
echo "  - All subcharts render with parent's global.imageRegistry (registry.example.com)"
echo "  - Environment is 'production' (from parent global, not subchart default)"
echo "  - Conditions correctly enable/disable subcharts"
echo "  - Import-values work correctly"
