#!/bin/bash
# Deploy Jenkins for Lab 03 - Credentials Binding

CONTAINER_NAME="jenkins-lab-03"

echo "🚀 Starting Jenkins for Lab 03: Credentials Binding"

docker run -d \
  --name "$CONTAINER_NAME" \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_lab03_data:/var/jenkins_home \
  -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" \
  jenkins/jenkins:lts

echo "⏳ Waiting for Jenkins to start..."
sleep 30

echo "✅ Jenkins is running at http://localhost:8080"
echo "📋 Create credentials in Manage Jenkins → Credentials:"
echo "   - Add a 'Secret text' credential with ID 'aws-credentials'"
echo "   - Add a 'Secret text' credential with ID 'docker-registry-token'"
echo "📋 Then create a Pipeline job and paste the Jenkinsfile contents"
echo "🔍 Run the pipeline and observe the credential binding errors"
