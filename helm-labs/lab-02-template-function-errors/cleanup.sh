#!/bin/bash
# Lab 02: Cleanup
echo "=== Cleaning up Lab 02: Template Function Errors ==="
helm uninstall myrelease 2>/dev/null || echo "No release to uninstall (template-only lab)"
echo "Done."
