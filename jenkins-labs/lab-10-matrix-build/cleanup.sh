#!/bin/bash
# Cleanup Jenkins for Lab 10

CONTAINER_NAME="jenkins-lab-10"

echo "🧹 Cleaning up Lab 10..."
docker stop "$CONTAINER_NAME" 2>/dev/null
docker rm "$CONTAINER_NAME" 2>/dev/null
docker volume rm jenkins_lab10_data 2>/dev/null
echo "✅ Cleanup complete"
