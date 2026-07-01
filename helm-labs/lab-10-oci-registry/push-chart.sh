#!/bin/bash
# Broken chart push script
# Issues:
#   1. OCI URL is wrong (wrong-registry.io doesn't exist)
#   2. No helm registry login performed first

set -e

CHART_DIR="./mychart"
OCI_REGISTRY="oci://wrong-registry.io/charts"

echo "=== Packaging chart ==="
helm package "$CHART_DIR"

echo ""
echo "=== Pushing chart to OCI registry ==="
echo "Target: $OCI_REGISTRY"
echo ""

# Missing: helm registry login wrong-registry.io --username user --password pass
helm push mychart-0.1.0.tgz "$OCI_REGISTRY"

echo ""
echo "Chart pushed successfully!"
