#!/bin/bash
# Lab 05: File Permissions
# Creates files with wrong permissions and ownership

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[Lab 05] Deploying: File Permissions Issues"
echo "============================================="

# Create app directory structure
APP_DIR="/opt/lab05-app"
mkdir -p "$APP_DIR/logs"

# Copy config and app files
cp "$SCRIPT_DIR/config.conf" "$APP_DIR/config.conf"
cp "$SCRIPT_DIR/app.sh" "$APP_DIR/app.sh"

# Create an app user (if doesn't exist)
if ! id "appuser" &>/dev/null; then
    useradd -r -s /bin/false appuser 2>/dev/null || true
fi

# Set WRONG permissions - this is the bug
echo "[*] Setting broken permissions..."

# Config file: no permissions at all
chmod 0000 "$APP_DIR/config.conf"

# Log directory: owned by root, not writable by app
chown root:root "$APP_DIR/logs"
chmod 0700 "$APP_DIR/logs"

# App directory: wrong ownership
chown root:root "$APP_DIR"

# App script: not executable
chmod 0644 "$APP_DIR/app.sh"

echo ""
echo "[✓] Lab 05 deployed!"
echo "    Scenario: The application 'myapp' was deployed but fails to start."
echo "    The operations team says 'it works on their machine.'"
echo "    The app should be run as 'appuser'."
echo ""
echo "    Start investigating with:"
echo "      sudo -u appuser bash /opt/lab05-app/app.sh"
