#!/bin/bash
# Cleanup Jenkins for Lab 03

CONTAINER_NAME="jenkins-lab-03"

echo "🧹 Cleaning up Lab 03..."
docker stop "$CONTAINER_NAME" 2>/dev/null
docker rm "$CONTAINER_NAME" 2>/dev/null
docker volume rm jenkins_lab03_data 2>/dev/null
echo "✅ Cleanup complete"
