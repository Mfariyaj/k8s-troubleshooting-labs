#!/bin/bash
# Lab 08: CI Cache Misses - Cleanup
LAB_NAME="lab-08-ci-cache-miss"
WORK_DIR="/tmp/cicd-labs/${LAB_NAME}"

echo "[${LAB_NAME}] Cleaning up..."
rm -rf "${WORK_DIR}"
echo "[${LAB_NAME}] Cleaned up ${WORK_DIR}"
