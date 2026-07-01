#!/bin/bash
# Deploy Jenkins for Lab 09 - Workspace Disk Full

CONTAINER_NAME="jenkins-lab-09"

echo "🚀 Starting Jenkins for Lab 09: Workspace Disk Full"

# Start with limited disk to trigger the issue faster
docker run -d \
  --name "$CONTAINER_NAME" \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_lab09_data:/var/jenkins_home \
  --storage-opt size=3G \
  -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" \
  jenkins/jenkins:lts 2>/dev/null || \
docker run -d \
  --name "$CONTAINER_NAME" \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_lab09_data:/var/jenkins_home \
  -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" \
  jenkins/jenkins:lts

echo "⏳ Waiting for Jenkins to start..."
sleep 30

echo "✅ Jenkins is running at http://localhost:8080"
echo "📋 Create a Pipeline job and paste the Jenkinsfile contents"
echo "🔍 Run the pipeline 3-4 times and observe disk space exhaustion"
echo "💡 Check: docker exec $CONTAINER_NAME du -sh /var/jenkins_home/workspace/*"
