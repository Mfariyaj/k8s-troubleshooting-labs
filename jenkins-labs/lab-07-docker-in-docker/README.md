# Lab 07: Docker-in-Docker

## Difficulty: ⭐⭐⭐ Hard

## Scenario

A pipeline builds and pushes Docker images, but Jenkins is running in a Docker container without access to the Docker daemon. All Docker commands fail.

## Console Error Output

```
[Pipeline] script
[Pipeline] {
[Pipeline] sh
+ docker build -t my-app:15 .
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?

ERROR: script returned exit code 1

org.jenkinsci.plugins.docker.workflow.client.DockerClient$DockerException: 
docker: Cannot connect to the Docker daemon at unix:///var/run/docker.sock.
    at org.jenkinsci.plugins.docker.workflow.Docker.build(...)
```

## Hints

1. Jenkins is running inside a container that doesn't have access to Docker
2. You need to mount the Docker socket: `-v /var/run/docker.sock:/var/run/docker.sock`
3. The Jenkins user needs permission to access the socket (group `docker`)
4. Alternative: use Docker-in-Docker (DinD) with a privileged sidecar container
5. Check the `deploy.sh` — it's missing the volume mount

## What to Fix

- Add `-v /var/run/docker.sock:/var/run/docker.sock` to the `docker run` command in deploy.sh
- Add `-v $(which docker):/usr/bin/docker` or install Docker CLI in the image
- Ensure the jenkins user has access: add `-u root` or configure group permissions
