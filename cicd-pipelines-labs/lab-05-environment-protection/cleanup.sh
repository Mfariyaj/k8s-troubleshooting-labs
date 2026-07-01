#!/bin/bash
# Lab 05: Environment Protection Rules - Cleanup
LAB_NAME="lab-05-environment-protection"
WORK_DIR="/tmp/cicd-labs/${LAB_NAME}"

echo "[${LAB_NAME}] Cleaning up..."
rm -rf "${WORK_DIR}"
echo "[${LAB_NAME}] Cleaned up ${WORK_DIR}"
