#!/bin/bash
# Cleanup Jenkins for Lab 06

CONTAINER_NAME="jenkins-lab-06"

echo "🧹 Cleaning up Lab 06..."
docker stop "$CONTAINER_NAME" 2>/dev/null
docker rm "$CONTAINER_NAME" 2>/dev/null
docker volume rm jenkins_lab06_data 2>/dev/null
echo "✅ Cleanup complete"
