#!/bin/bash
# Deploy Jenkins for Lab 06 - Artifact Failures

CONTAINER_NAME="jenkins-lab-06"

echo "🚀 Starting Jenkins for Lab 06: Artifact Failures"

docker run -d \
  --name "$CONTAINER_NAME" \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_lab06_data:/var/jenkins_home \
  -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" \
  jenkins/jenkins:lts

echo "⏳ Waiting for Jenkins to start..."
sleep 30

echo "✅ Jenkins is running at http://localhost:8080"
echo "📋 Create a Pipeline job and paste the Jenkinsfile contents"
echo "🔍 Run the pipeline and observe the artifact archiving errors"
