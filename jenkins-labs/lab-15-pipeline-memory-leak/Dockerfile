# Dockerfile for Lab 15 - Jenkins with intentionally LOW memory
# This makes the memory leak patterns more visible and reproducible
# In production, the leak is the same but takes longer to manifest

FROM jenkins/jenkins:2.426.1-lts

USER root

# Install monitoring tools
RUN apt-get update && apt-get install -y \
    procps \
    htop \
    && rm -rf /var/lib/apt/lists/*

USER jenkins

# Install required plugins
RUN jenkins-plugin-cli --plugins \
    workflow-aggregator:latest \
    pipeline-stage-view:latest \
    blueocean:latest \
    configuration-as-code:latest

# Set intentionally LOW heap to make OOM happen faster
# In production, the same leak occurs but takes hours/days to manifest
ENV JAVA_OPTS="-Xms128m -Xmx256m \
    -XX:+HeapDumpOnOutOfMemoryError \
    -XX:HeapDumpPath=/var/jenkins_home/heapdumps \
    -XX:+UseG1GC \
    -XX:+PrintGCDetails \
    -Xloggc:/var/jenkins_home/gc.log \
    -Djenkins.install.runSetupWizard=false"

# Create heapdump directory
RUN mkdir -p /var/jenkins_home/heapdumps
