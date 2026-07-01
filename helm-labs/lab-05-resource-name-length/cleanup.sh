#!/bin/bash
# Lab 05: Cleanup
echo "=== Cleaning up Lab 05: Resource Name Length ==="
helm uninstall my-production-release 2>/dev/null || echo "No release to uninstall"
echo "Done."
