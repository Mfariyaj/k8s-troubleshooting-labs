#!/bin/bash
# Cleanup Jenkins for Lab 01

CONTAINER_NAME="jenkins-lab-01"

echo "🧹 Cleaning up Lab 01..."
docker stop "$CONTAINER_NAME" 2>/dev/null
docker rm "$CONTAINER_NAME" 2>/dev/null
docker volume rm jenkins_lab01_data 2>/dev/null
echo "✅ Cleanup complete"
