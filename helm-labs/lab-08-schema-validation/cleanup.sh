#!/bin/bash
# Lab 08: Cleanup
echo "=== Cleaning up Lab 08: Schema Validation ==="
helm uninstall myrelease 2>/dev/null || echo "No release to uninstall (template-only lab)"
echo "Done."
