#!/bin/bash
# Lab 06: Container Registry Push Failures - Cleanup
LAB_NAME="lab-06-container-registry-push"
WORK_DIR="/tmp/cicd-labs/${LAB_NAME}"

echo "[${LAB_NAME}] Cleaning up..."
rm -rf "${WORK_DIR}"
echo "[${LAB_NAME}] Cleaned up ${WORK_DIR}"
