#!/bin/bash
# Lab 10: Cleanup
echo "=== Cleaning up Lab 10: OCI Registry ==="
rm -f mychart-0.1.0.tgz 2>/dev/null
helm uninstall myrelease 2>/dev/null || echo "No release to uninstall"
echo "Done."
