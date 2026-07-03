#!/bin/bash
echo "🚀 Deploying all labs..."
for lab in lab-*/; do
  echo "--- $lab ---"
  cd "$lab" && bash deploy.sh && cd ..
done
