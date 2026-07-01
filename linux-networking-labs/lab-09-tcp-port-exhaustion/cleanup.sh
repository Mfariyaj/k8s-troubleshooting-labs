#!/bin/bash
# Cleanup for Lab 09: TCP Port Exhaustion

echo "[Lab 09] Cleaning up..."

# Kill connection generator
if [ -f /tmp/.lab09-pid ]; then
    kill "$(cat /tmp/.lab09-pid)" 2>/dev/null
    rm -f /tmp/.lab09-pid
fi

pkill -f "connection-generator.py" 2>/dev/null

# Restore original port range
if [ -f /tmp/.lab09-orig-port-range ]; then
    cat /tmp/.lab09-orig-port-range > /proc/sys/net/ipv4/ip_local_port_range 2>/dev/null || true
    rm -f /tmp/.lab09-orig-port-range
fi

# Restore TCP fin timeout
if [ -f /tmp/.lab09-orig-tw ]; then
    cat /tmp/.lab09-orig-tw > /proc/sys/net/ipv4/tcp_fin_timeout 2>/dev/null || true
    rm -f /tmp/.lab09-orig-tw
fi

rm -f /tmp/.lab09-output.log

sleep 2
echo "[✓] Lab 09 cleaned up. Connections released, port range restored."
echo "    Current port range: $(cat /proc/sys/net/ipv4/ip_local_port_range)"
