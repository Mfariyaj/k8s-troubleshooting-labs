#!/bin/bash
# Cleanup for Lab 07: Cron Not Running

echo "[Lab 07] Cleaning up..."

# Restore original crontab
if [ -f /tmp/.lab07-crontab-backup ]; then
    if [ -s /tmp/.lab07-crontab-backup ]; then
        crontab /tmp/.lab07-crontab-backup
    else
        crontab -r 2>/dev/null || true
    fi
    rm -f /tmp/.lab07-crontab-backup
else
    # Remove the broken crontab entirely
    crontab -r 2>/dev/null || true
fi

# Remove lab files
rm -rf /tmp/lab07-*.log
rm -rf /tmp/lab07-cron-logs
rm -rf /opt/lab07-scripts

echo "[✓] Lab 07 cleaned up. Crontab restored."
