#!/bin/bash
# This script should run as a cron job
# It performs a simple backup/timestamp operation

LOG_DIR="/tmp/lab07-cron-logs"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
BACKUP_FILE="$LOG_DIR/backup-$(date +%Y%m%d-%H%M%S).txt"

echo "Backup started at $TIMESTAMP" > "$BACKUP_FILE"
echo "System: $(hostname)" >> "$BACKUP_FILE"
echo "Uptime: $(uptime)" >> "$BACKUP_FILE"
echo "Disk usage:" >> "$BACKUP_FILE"
df -h >> "$BACKUP_FILE"
echo "Backup completed at $(date '+%Y-%m-%d %H:%M:%S')" >> "$BACKUP_FILE"

echo "[$TIMESTAMP] Backup completed: $BACKUP_FILE"
