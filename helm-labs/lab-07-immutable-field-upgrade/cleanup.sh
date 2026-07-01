#!/bin/bash
# Lab 07: Cleanup
echo "=== Cleaning up Lab 07: Immutable Field Upgrade ==="
helm uninstall myrelease 2>/dev/null || echo "No release to uninstall"
echo "Done."
