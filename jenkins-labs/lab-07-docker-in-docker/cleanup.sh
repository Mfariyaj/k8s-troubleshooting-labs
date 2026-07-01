#!/bin/bash
# Cleanup Jenkins for Lab 07

CONTAINER_NAME="jenkins-lab-07"

echo "🧹 Cleaning up Lab 07..."
docker stop "$CONTAINER_NAME" 2>/dev/null
docker rm "$CONTAINER_NAME" 2>/dev/null
docker volume rm jenkins_lab07_data 2>/dev/null
echo "✅ Cleanup complete"
