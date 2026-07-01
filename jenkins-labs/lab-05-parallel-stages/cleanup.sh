#!/bin/bash
# Cleanup Jenkins for Lab 05

CONTAINER_NAME="jenkins-lab-05"

echo "🧹 Cleaning up Lab 05..."
docker stop "$CONTAINER_NAME" 2>/dev/null
docker rm "$CONTAINER_NAME" 2>/dev/null
docker volume rm jenkins_lab05_data 2>/dev/null
echo "✅ Cleanup complete"
