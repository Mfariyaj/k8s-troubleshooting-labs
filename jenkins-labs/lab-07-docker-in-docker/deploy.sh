#!/bin/bash
# Deploy Jenkins for Lab 07 - Docker-in-Docker
# BUG: Missing -v /var/run/docker.sock:/var/run/docker.sock

CONTAINER_NAME="jenkins-lab-07"

echo "🚀 Starting Jenkins for Lab 07: Docker-in-Docker"

# INTENTIONALLY BROKEN: No Docker socket mount
docker run -d \
  --name "$CONTAINER_NAME" \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_lab07_data:/var/jenkins_home \
  -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" \
  jenkins/jenkins:lts

echo "⏳ Waiting for Jenkins to start..."
sleep 30

echo "✅ Jenkins is running at http://localhost:8080"
echo "📋 Install the Docker Pipeline plugin"
echo "📋 Create a Pipeline job and paste the Jenkinsfile contents"
echo "🔍 Run the pipeline and observe the Docker connection error"
echo ""
echo "💡 Notice: The container was started WITHOUT Docker socket access!"
