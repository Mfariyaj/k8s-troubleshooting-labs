#!/bin/bash
# Application startup script that reads configuration
# This simulates an application service trying to start

APP_NAME="myapp"
CONFIG_DIR="/opt/lab05-app"
CONFIG_FILE="$CONFIG_DIR/config.conf"
LOG_DIR="/opt/lab05-app/logs"
PID_FILE="/opt/lab05-app/app.pid"

echo "[$APP_NAME] Starting application..."
echo "[$APP_NAME] Reading configuration from $CONFIG_FILE"

# Try to read config
if ! cat "$CONFIG_FILE" > /dev/null 2>&1; then
    echo "[$APP_NAME] ERROR: Cannot read configuration file: $CONFIG_FILE"
    echo "[$APP_NAME] Permission denied!"
    exit 1
fi

# Try to write to log directory
if ! touch "$LOG_DIR/app.log" 2>&1; then
    echo "[$APP_NAME] ERROR: Cannot write to log directory: $LOG_DIR"
    echo "[$APP_NAME] Permission denied!"
    exit 1
fi

# Try to write PID file
if ! echo $$ > "$PID_FILE" 2>&1; then
    echo "[$APP_NAME] ERROR: Cannot write PID file: $PID_FILE"
    echo "[$APP_NAME] Permission denied!"
    exit 1
fi

echo "[$APP_NAME] Application started successfully (PID: $$)"
