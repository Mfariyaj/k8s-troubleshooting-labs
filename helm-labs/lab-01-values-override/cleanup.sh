#!/bin/bash
# Lab 01: Cleanup
echo "=== Cleaning up Lab 01: Values Override Precedence ==="
helm uninstall myrelease 2>/dev/null || echo "No release to uninstall (template-only lab)"
echo "Done."
