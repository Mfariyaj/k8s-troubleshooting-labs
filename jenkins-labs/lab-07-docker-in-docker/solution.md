## Solution: Docker-in-Docker

### Root Cause

Jenkins runs inside a Docker container but the Docker socket (`/var/run/docker.sock`) is not mounted. The Jenkins user also lacks permission to access the socket (not in the `docker` group). All `docker` commands fail with "Cannot connect to the Docker daemon."

### Step-by-Step Fix

1. Mount the Docker socket: `-v /var/run/docker.sock:/var/run/docker.sock`
2. Add the jenkins user to the docker group: `--group-add $(getent group docker | cut -d: -f3)`
3. Optionally mount Docker CLI binary or install it in the image

### Fixed deploy.sh

```bash
#!/bin/bash
docker run -d \
  --name jenkins-lab-07 \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_lab07_data:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(which docker):/usr/bin/docker \
  --group-add $(getent group docker | cut -d: -f3) \
  jenkins/jenkins:lts
```

### Fixed Dockerfile (alternative approach)

```dockerfile
FROM jenkins/jenkins:lts
USER root
RUN apt-get update && apt-get install -y docker.io && rm -rf /var/lib/apt/lists/*
RUN usermod -aG docker jenkins
USER jenkins
```

### Jenkinsfile (no changes needed — issue is infrastructure)

The Jenkinsfile is correct. The fix is entirely in how the Jenkins container is launched.

### Verification

```bash
# Verify socket is mounted
docker exec jenkins-lab-07 ls -la /var/run/docker.sock
# Verify docker access
docker exec jenkins-lab-07 docker version
# Pipeline should build/push images without socket errors
```
