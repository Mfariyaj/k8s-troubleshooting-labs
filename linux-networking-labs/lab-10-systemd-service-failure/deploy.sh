#!/bin/bash
# Lab 10: Systemd Service Failure
# Installs a broken systemd service with multiple issues

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[Lab 10] Deploying: Systemd Service Failure"
echo "=============================================="

# Check for systemd
if ! command -v systemctl &>/dev/null; then
    echo "[!] Error: systemd not available on this system."
    exit 1
fi

# Install the actual application (but at the WRONG path per the service file)
echo "[*] Installing application..."
cp "$SCRIPT_DIR/app.sh" /usr/local/bin/lab10-app
chmod +x /usr/local/bin/lab10-app

# Install the broken service unit file
echo "[*] Installing broken service file..."
cp "$SCRIPT_DIR/broken-app.service" /etc/systemd/system/lab10-app.service

# Reload systemd to pick up the new unit
systemctl daemon-reload

# Try to start the service (it will fail)
echo "[*] Attempting to start the broken service..."
systemctl start lab10-app.service 2>/dev/null || true

# Wait for it to fail
sleep 3

echo ""
echo "[✓] Lab 10 deployed!"
echo "    Scenario: A new application service was installed but it"
echo "    refuses to start properly. The team says the app binary"
echo "    works fine when run manually."
echo ""
echo "    Start investigating with:"
echo "      systemctl status lab10-app"
echo "      journalctl -u lab10-app --no-pager"
echo "      cat /etc/systemd/system/lab10-app.service"
