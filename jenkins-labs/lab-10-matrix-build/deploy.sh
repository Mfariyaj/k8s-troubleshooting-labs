#!/bin/bash
# Deploy Jenkins for Lab 10 - Matrix Build

CONTAINER_NAME="jenkins-lab-10"

echo "🚀 Starting Jenkins for Lab 10: Matrix Build"

docker run -d \
  --name "$CONTAINER_NAME" \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_lab10_data:/var/jenkins_home \
  -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" \
  jenkins/jenkins:lts

echo "⏳ Waiting for Jenkins to start..."
sleep 30

echo "✅ Jenkins is running at http://localhost:8080"
echo "📋 Create a Pipeline job and paste the Jenkinsfile contents"
echo "🔍 Run the pipeline and observe the matrix axis parsing errors"
echo "💡 This lab tests understanding of declarative matrix syntax"
