#!/bin/bash
# Cleanup Jenkins for Lab 04

CONTAINER_NAME="jenkins-lab-04"

echo "🧹 Cleaning up Lab 04..."
docker stop "$CONTAINER_NAME" 2>/dev/null
docker rm "$CONTAINER_NAME" 2>/dev/null
docker volume rm jenkins_lab04_data 2>/dev/null
echo "✅ Cleanup complete"
