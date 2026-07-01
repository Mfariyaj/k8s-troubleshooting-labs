#!/bin/bash
# Lab 09: Cleanup
echo "=== Cleaning up Lab 09: Library Chart ==="
helm uninstall myrelease 2>/dev/null || echo "No release to uninstall"
rm -rf mychart/charts/ 2>/dev/null
echo "Done."
