#!/bin/bash
# Deploy Jenkins for Lab 08 - Webhook Triggers

CONTAINER_NAME="jenkins-lab-08"

echo "🚀 Starting Jenkins for Lab 08: Webhook Triggers"

docker run -d \
  --name "$CONTAINER_NAME" \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_lab08_data:/var/jenkins_home \
  -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" \
  jenkins/jenkins:lts

echo "⏳ Waiting for Jenkins to start..."
sleep 30

echo "✅ Jenkins is running at http://localhost:8080"
echo "📋 Install the GitHub plugin"
echo "📋 Create a Pipeline job and paste the Jenkinsfile contents"
echo "🔍 Try sending a webhook payload:"
echo "   curl -X POST http://localhost:8080/github-webhook/ \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d @webhook-payload.json"
echo "🔍 Observe that the build doesn't trigger from the webhook"
