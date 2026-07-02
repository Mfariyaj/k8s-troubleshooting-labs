#!/bin/bash
# Install ALL plugins required for Jenkins troubleshooting labs
# Usage: ./install-plugins.sh [container-name]
#
# This installs all plugins and restarts Jenkins.
# After restart, Jenkins will be ready for ALL 15 labs.

CONTAINER="${1:-jenkins-lab-01}"

echo "🔌 Installing ALL plugins for Jenkins labs..."
echo "   Container: $CONTAINER"
echo ""

# Check if container is running
if ! docker ps --filter "name=$CONTAINER" --format "{{.Names}}" | grep -q "$CONTAINER"; then
    echo "❌ Container '$CONTAINER' is not running!"
    echo "   Start it first: cd lab-01-pipeline-syntax && ./deploy.sh"
    exit 1
fi

# Install plugins
echo "📦 Installing plugins (this takes 2-3 minutes)..."
docker exec "$CONTAINER" jenkins-plugin-cli --plugins \
    docker-workflow \
    credentials-binding \
    pipeline-groovy-lib \
    pipeline-utility-steps \
    pipeline-stage-view \
    pipeline-build-step \
    pipeline-input-step \
    pipeline-milestone-step \
    git \
    git-parameter \
    github \
    github-branch-source \
    docker-plugin \
    docker-commons \
    kubernetes \
    kubernetes-credentials \
    kubernetes-client-api \
    ldap \
    matrix-auth \
    role-strategy \
    authorize-project \
    configuration-as-code \
    ws-cleanup \
    slack \
    email-ext \
    junit \
    htmlpublisher \
    cobertura \
    warnings-ng \
    coverage \
    blueocean \
    ansicolor \
    timestamper \
    rebuild \
    http_request \
    job-dsl \
    ssh-agent \
    throttle-concurrents \
    gradle \
    ant

if [ $? -ne 0 ]; then
    echo "❌ Plugin installation failed!"
    exit 1
fi

echo ""
echo "🔄 Restarting Jenkins to activate plugins..."
docker restart "$CONTAINER"

echo "⏳ Waiting for Jenkins to come back up..."
for i in $(seq 1 24); do
    sleep 5
    status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/login 2>/dev/null)
    if [ "$status" = "200" ]; then
        echo ""
        echo "✅ Jenkins is ready with ALL plugins!"
        echo ""
        echo "🌐 Access Jenkins: http://localhost:8080"
        echo "🔵 Blue Ocean UI: http://localhost:8080/blue"
        echo ""
        echo "You can now perform ALL 15 Jenkins labs!"
        exit 0
    fi
    printf "."
done

echo ""
echo "⚠️  Jenkins is taking longer than expected. Check: docker logs $CONTAINER"
