#!/bin/bash
# Deploy Jenkins for Lab 05 - Parallel Stages

CONTAINER_NAME="jenkins-lab-05"

echo "🚀 Starting Jenkins for Lab 05: Parallel Stages"

docker run -d \
  --name "$CONTAINER_NAME" \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_lab05_data:/var/jenkins_home \
  -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" \
  jenkins/jenkins:lts

echo "⏳ Waiting for Jenkins to start..."
sleep 30

echo "✅ Jenkins is running at http://localhost:8080"
echo "📋 Create a Pipeline job and paste the Jenkinsfile contents"
echo "🔍 Run the pipeline multiple times and observe inconsistent test-results.txt"
