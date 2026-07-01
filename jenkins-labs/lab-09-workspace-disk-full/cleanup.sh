#!/bin/bash
# Cleanup Jenkins for Lab 09

CONTAINER_NAME="jenkins-lab-09"

echo "🧹 Cleaning up Lab 09..."
docker stop "$CONTAINER_NAME" 2>/dev/null
docker rm "$CONTAINER_NAME" 2>/dev/null
docker volume rm jenkins_lab09_data 2>/dev/null
echo "✅ Cleanup complete"
