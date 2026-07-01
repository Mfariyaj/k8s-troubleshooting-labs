#!/bin/bash
# Cleanup for Lab 03: Firewall Blocking

echo "[Lab 03] Cleaning up..."

# Kill the app server
if [ -f /tmp/.lab03-app-pid ]; then
    kill "$(cat /tmp/.lab03-app-pid)" 2>/dev/null
    rm -f /tmp/.lab03-app-pid
fi

# Kill any remaining app-server.py processes from this lab
pkill -f "app-server.py" 2>/dev/null

# Remove the iptables DROP rule
iptables -D INPUT -p tcp --dport 8080 -j DROP 2>/dev/null

# Restore original iptables rules if backup exists
if [ -f /tmp/.lab03-iptables-backup ]; then
    iptables-restore < /tmp/.lab03-iptables-backup 2>/dev/null
    rm -f /tmp/.lab03-iptables-backup
fi

echo "[✓] Lab 03 cleaned up. Firewall rules restored."
