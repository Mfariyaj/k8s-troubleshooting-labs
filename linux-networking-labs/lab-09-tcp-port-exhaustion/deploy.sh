#!/bin/bash
# Lab 09: TCP Port Exhaustion
# Opens many TCP connections to exhaust ephemeral ports

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[Lab 09] Deploying: TCP Port Exhaustion"
echo "=========================================="

# Save original port range for restoration
echo "[*] Saving current port range..."
cat /proc/sys/net/ipv4/ip_local_port_range > /tmp/.lab09-orig-port-range

# Narrow the ephemeral port range to make exhaustion faster and safer
echo "[*] Narrowing ephemeral port range for faster simulation..."
echo "50000 51000" > /proc/sys/net/ipv4/ip_local_port_range 2>/dev/null || true

# Also reduce TIME_WAIT timeout to help cleanup
ORIG_TW=$(cat /proc/sys/net/ipv4/tcp_fin_timeout 2>/dev/null)
echo "$ORIG_TW" > /tmp/.lab09-orig-tw 2>/dev/null

# Start the connection generator
export LAB09_MAX_CONNS=900
echo "[*] Starting connection generator (target: $LAB09_MAX_CONNS connections)..."
python3 "$SCRIPT_DIR/connection-generator.py" > /tmp/.lab09-output.log 2>&1 &
PID=$!
echo "$PID" > /tmp/.lab09-pid

# Wait for connections to be established
sleep 8

echo ""
echo "[✓] Lab 09 deployed!"
echo "    Scenario: New TCP connections are failing. Applications report"
echo "    'Cannot assign requested address' errors. The system seems to"
echo "    have run out of available ports."
echo ""
echo "    Start investigating with:"
echo "      ss -s"
echo "      ss -tn | wc -l"
echo "      cat /proc/sys/net/ipv4/ip_local_port_range"
echo "      cat /tmp/.lab09-output.log"
