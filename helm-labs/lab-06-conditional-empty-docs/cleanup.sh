#!/bin/bash
# Lab 06: Cleanup
echo "=== Cleaning up Lab 06: Conditional Empty Documents ==="
helm uninstall myrelease 2>/dev/null || echo "No release to uninstall"
echo "Done."
