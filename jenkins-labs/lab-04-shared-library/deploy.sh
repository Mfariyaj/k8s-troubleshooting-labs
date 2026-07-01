#!/bin/bash
# Deploy Jenkins for Lab 04 - Shared Library

CONTAINER_NAME="jenkins-lab-04"

echo "🚀 Starting Jenkins for Lab 04: Shared Library"

docker run -d \
  --name "$CONTAINER_NAME" \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_lab04_data:/var/jenkins_home \
  -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" \
  jenkins/jenkins:lts

echo "⏳ Waiting for Jenkins to start..."
sleep 30

echo "✅ Jenkins is running at http://localhost:8080"
echo "📋 Configure a Global Pipeline Library:"
echo "   Manage Jenkins → Configure System → Global Pipeline Libraries"
echo "   Name: my-shared-lib"
echo "   Source: point to a Git repo containing vars/buildHelper.groovy"
echo "📋 Then create a Pipeline job and paste the Jenkinsfile contents"
echo "🔍 Run the pipeline and observe the library resolution error"
