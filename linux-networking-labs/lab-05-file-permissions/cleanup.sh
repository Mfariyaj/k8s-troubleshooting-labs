#!/bin/bash
# Cleanup for Lab 05: File Permissions

echo "[Lab 05] Cleaning up..."

# Remove the app directory
rm -rf /opt/lab05-app

# Remove the user (optional - don't remove if it was pre-existing)
if id "appuser" &>/dev/null; then
    userdel appuser 2>/dev/null || true
fi

echo "[✓] Lab 05 cleaned up."
