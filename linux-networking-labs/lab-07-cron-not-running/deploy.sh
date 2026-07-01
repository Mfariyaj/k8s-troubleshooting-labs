#!/bin/bash
# Lab 07: Cron Not Running
# Installs a broken crontab with multiple issues

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[Lab 07] Deploying: Cron Not Running"
echo "======================================="

# Back up existing crontab
echo "[*] Backing up existing crontab..."
crontab -l > /tmp/.lab07-crontab-backup 2>/dev/null || true

# Install the script-to-run
echo "[*] Installing scripts..."
mkdir -p /opt/lab07-scripts
cp "$SCRIPT_DIR/script-to-run.sh" /opt/lab07-scripts/script-to-run.sh
chmod +x /opt/lab07-scripts/script-to-run.sh

# Install the broken crontab
echo "[*] Installing broken crontab..."
crontab "$SCRIPT_DIR/broken-crontab"

echo ""
echo "[✓] Lab 07 deployed!"
echo "    Scenario: A cron job was set up to run a backup/cleanup"
echo "    script every minute, but it never executes. No output"
echo "    is being generated, and the backup files are missing."
echo ""
echo "    Start investigating with:"
echo "      crontab -l"
echo "      grep CRON /var/log/syslog (or journalctl -u cron)"
echo "      systemctl status cron"
