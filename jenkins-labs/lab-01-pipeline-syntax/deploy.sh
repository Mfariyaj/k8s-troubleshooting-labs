#!/bin/bash
# Deploy Jenkins for Lab 01 - Pipeline Syntax Errors

CONTAINER_NAME="jenkins-lab-01"

echo "🚀 Starting Jenkins for Lab 01: Pipeline Syntax Errors"

docker run -d \
  --name "$CONTAINER_NAME" \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_lab01_data:/var/jenkins_home \
  jenkins/jenkins:lts

echo "⏳ Waiting for Jenkins to start..."
sleep 30

echo "🔑 Initial admin password:"
docker exec "$CONTAINER_NAME" cat /var/jenkins_home/secrets/initialAdminPassword

echo ""
echo "✅ Jenkins is running at http://localhost:8080"
echo "📋 Create a Pipeline job and paste the Jenkinsfile contents"
echo "🔍 Run the pipeline and observe the syntax errors"
