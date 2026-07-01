#!/bin/bash
# Cleanup Jenkins for Lab 08

CONTAINER_NAME="jenkins-lab-08"

echo "🧹 Cleaning up Lab 08..."
docker stop "$CONTAINER_NAME" 2>/dev/null
docker rm "$CONTAINER_NAME" 2>/dev/null
docker volume rm jenkins_lab08_data 2>/dev/null
echo "✅ Cleanup complete"
