#!/bin/bash
# Cleanup for Lab 04: DNS Resolution

echo "[Lab 04] Cleaning up..."

# Restore original resolv.conf
if [ -f /tmp/.lab04-resolv-backup ]; then
    cp /tmp/.lab04-resolv-backup /etc/resolv.conf
    rm -f /tmp/.lab04-resolv-backup
    echo "[✓] Lab 04 cleaned up. /etc/resolv.conf restored."
else
    echo "[!] No backup found. Restoring default resolv.conf..."
    cat > /etc/resolv.conf << 'EOF'
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
    echo "[✓] Lab 04 cleaned up with default nameservers."
fi
