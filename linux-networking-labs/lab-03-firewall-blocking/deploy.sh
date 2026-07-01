#!/bin/bash
# Lab 03: Firewall Blocking
# Starts an HTTP server on port 8080, then blocks it with iptables

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[Lab 03] Deploying: Firewall Blocking"
echo "======================================="

# Check for iptables
if ! command -v iptables &>/dev/null; then
    echo "[!] Error: iptables not found. Install with: apt install iptables"
    exit 1
fi

# Start the application server in background
echo "[*] Starting HTTP application server on port 8080..."
python3 "$SCRIPT_DIR/app-server.py" &
APP_PID=$!
echo "$APP_PID" > /tmp/.lab03-app-pid

# Wait for server to start
sleep 2

# Verify server is running
if ! kill -0 "$APP_PID" 2>/dev/null; then
    echo "[!] Failed to start app server. Is port 8080 already in use?"
    exit 1
fi

# Save current iptables rules for restoration
iptables-save > /tmp/.lab03-iptables-backup 2>/dev/null

# Add DROP rule for port 8080 (blocks incoming connections)
echo "[*] Adding iptables DROP rule for port 8080..."
iptables -I INPUT -p tcp --dport 8080 -j DROP

echo ""
echo "[✓] Lab 03 deployed!"
echo "    Scenario: The application server was deployed and the process"
echo "    is running, but users report they cannot access it."
echo "    The app should be available at http://localhost:8080"
echo ""
echo "    Start investigating with: curl -m 5 http://localhost:8080"
