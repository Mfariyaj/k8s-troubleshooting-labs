#!/bin/bash
# Cleanup for Lab 10: Systemd Service Failure

echo "[Lab 10] Cleaning up..."

# Stop and disable the service
systemctl stop lab10-app.service 2>/dev/null
systemctl disable lab10-app.service 2>/dev/null

# Reset failed state
systemctl reset-failed lab10-app.service 2>/dev/null

# Remove service file
rm -f /etc/systemd/system/lab10-app.service

# Remove application binary
rm -f /usr/local/bin/lab10-app

# Reload systemd
systemctl daemon-reload

echo "[✓] Lab 10 cleaned up. Service removed."
