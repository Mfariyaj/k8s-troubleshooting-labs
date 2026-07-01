#!/bin/bash
# Lab 04: DNS Resolution Failure
# Corrupts /etc/resolv.conf with an unreachable nameserver

echo "[Lab 04] Deploying: DNS Resolution Failure"
echo "============================================"

# Back up existing resolv.conf
if [ ! -f /tmp/.lab04-resolv-backup ]; then
    echo "[*] Backing up /etc/resolv.conf..."
    cp /etc/resolv.conf /tmp/.lab04-resolv-backup
else
    echo "[*] Backup already exists, skipping..."
fi

# Write a broken resolv.conf with unreachable nameserver
# 192.0.2.1 is in the TEST-NET-1 range (RFC 5737) — guaranteed unreachable
echo "[*] Corrupting /etc/resolv.conf with wrong nameserver..."
cat > /etc/resolv.conf << 'EOF'
# This file was updated by the network team
# Nameserver configuration - DO NOT EDIT
nameserver 192.0.2.1
nameserver 198.51.100.1
options timeout:1 attempts:1
EOF

echo ""
echo "[✓] Lab 04 deployed!"
echo "    Scenario: After a network change, applications report"
echo "    DNS resolution failures. Services can't resolve hostnames."
echo "    IP connectivity appears to be working fine."
echo ""
echo "    Start investigating with: dig google.com"
echo "    Or: nslookup google.com"
echo ""
echo "    ⚠️  Note: This lab modifies /etc/resolv.conf."
echo "    Run cleanup.sh to restore original configuration."
