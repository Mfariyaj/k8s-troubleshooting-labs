## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (builds and runs broken containers)
2. Check: `docker ps`, `docker logs <container>`
3. Test: Try `curl`, `docker exec`, check connectivity
4. Observe the failure and identify root cause
5. Fix the Dockerfile/docker-compose.yml and rebuild
6. Check `solution.md` if stuck

---

# Lab 10 - Registry Authentication Failure

## Difficulty: ⭐⭐⭐⭐

## Scenario
A CI/CD pipeline is trying to deploy a microservices application that pulls images from a private Docker registry. The deployment fails because it can't authenticate to the registry to pull the images.

## What You'll See
When you run `./deploy.sh`:

```
$ docker compose pull
[+] Pulling 3/3
 ⠿ api Error
 ⠿ worker Error
 ⠿ scheduler Error

Error response from daemon: Head "https://registry.internal.company.io/v2/myteam/api-service/manifests/v2.1.0":
  unauthorized: authentication required

Error response from daemon: pull access denied for registry.internal.company.io/myteam/worker-service,
  repository does not exist or may require 'docker login'
```

## Hints
1. Is the registry URL correct? Can you resolve the hostname?
2. Has `docker login` been run for this registry?
3. Check if there are any credentials stored in `~/.docker/config.json`
4. Is the image tag/version correct?
5. Does the registry use a non-standard port?

## Troubleshooting Commands
```bash
# Check if registry is reachable
curl -v https://registry.internal.company.io/v2/

# Check stored Docker credentials
cat ~/.docker/config.json

# Try logging in
docker login registry.internal.company.io

# Try pulling manually
docker pull registry.internal.company.io/myteam/api-service:v2.1.0

# Check DNS resolution
nslookup registry.internal.company.io

# Check docker compose config for image names
docker compose config
```

## Resolution
Multiple issues:
1. **Wrong registry URL**: The registry is at `registry.internal.company.io` but it's not accessible (doesn't exist in this lab context)
2. **No docker login**: No credentials stored for the private registry
3. **Non-existent tags**: Image tags reference versions that don't exist

**Fix for this lab (simulation):**
1. Replace private registry images with public equivalents or locally-built images
2. For real-world: Run `docker login <registry>` before pulling
3. Use credential helpers or docker config.json for CI/CD authentication
4. Verify image tags exist in the registry

**Real-world fix:**
```bash
# Login to registry
echo "$REGISTRY_PASSWORD" | docker login registry.company.io -u "$REGISTRY_USER" --password-stdin

# Or use config.json with auth token
mkdir -p ~/.docker
echo '{"auths":{"registry.company.io":{"auth":"base64_encoded_credentials"}}}' > ~/.docker/config.json
```
