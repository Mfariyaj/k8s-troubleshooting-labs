#!/bin/bash
# Lab 03: Matrix Strategy Overload - Cleanup
LAB_NAME="lab-03-matrix-strategy"
WORK_DIR="/tmp/cicd-labs/${LAB_NAME}"

echo "[${LAB_NAME}] Cleaning up..."
rm -rf "${WORK_DIR}"
echo "[${LAB_NAME}] Cleaned up ${WORK_DIR}"
