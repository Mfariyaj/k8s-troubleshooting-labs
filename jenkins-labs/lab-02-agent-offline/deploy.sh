#!/bin/bash
# Deploy Jenkins for Lab 02 - Agent Offline

echo "🚀 Starting Jenkins for Lab 02: Agent Offline"

docker-compose -f "$(dirname "$0")/docker-compose.yml" up -d

echo "⏳ Waiting for Jenkins to start..."
sleep 30

echo "🔑 Initial admin password:"
docker exec jenkins-lab-02 cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "(Setup wizard disabled)"

echo ""
echo "✅ Jenkins is running at http://localhost:8080"
echo "📋 Create a Pipeline job and paste the Jenkinsfile contents"
echo "🔍 Run the pipeline and observe the pending build"
