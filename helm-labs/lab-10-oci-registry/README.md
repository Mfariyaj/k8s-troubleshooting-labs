# Lab 10: OCI Registry Push Failures

## Difficulty: ⭐⭐⭐ Hard

## Scenario

A developer is trying to push their Helm chart to an OCI-compatible registry. Their `push-chart.sh` script packages the chart and pushes it, but it fails for two reasons:

1. The OCI registry URL `oci://wrong-registry.io/charts` points to a non-existent registry
2. No `helm registry login` was performed before the push

Your task: Fix the push script to use a valid OCI registry and authenticate properly.

## Error Output

```
$ ./push-chart.sh
=== Packaging chart ===
Successfully packaged chart and saved it to: /path/to/mychart-0.1.0.tgz

=== Pushing chart to OCI registry ===
Target: oci://wrong-registry.io/charts

Error: failed to do request: Head "https://wrong-registry.io/v2/charts/mychart/blobs/sha256:...":
  dial tcp: lookup wrong-registry.io: no such host

$ helm push mychart-0.1.0.tgz oci://wrong-registry.io/charts
Error: failed to do request: Head "https://wrong-registry.io/v2/charts/mychart/blobs/sha256:...":
  dial tcp: lookup wrong-registry.io: no such host
```

## Hints

1. The OCI URL `wrong-registry.io` doesn't exist. Use a valid registry like `ghcr.io/<username>`, `registry-1.docker.io/<username>`, or a local registry.
2. Before pushing, you must authenticate: `helm registry login <registry> --username <user> --password <pass>`
3. For testing, you can run a local OCI registry: `docker run -d -p 5000:5000 registry:2` and push to `oci://localhost:5000/charts`

## Commands

```bash
# Show the push failure
./push-chart.sh

# Fix: Start a local registry for testing
docker run -d -p 5000:5000 --name registry registry:2

# Fix: Login to registry (local doesn't need auth, but real ones do)
helm registry login localhost:5000 --username user --password pass

# Fix: Push to local registry
helm push mychart-0.1.0.tgz oci://localhost:5000/charts

# Verify it was pushed
helm show chart oci://localhost:5000/charts/mychart --version 0.1.0
```

## Root Cause

Two issues in the push workflow:
1. `wrong-registry.io` is not a real OCI registry — DNS lookup fails
2. No authentication was performed before the push (`helm registry login` missing)

## Fix

Update `push-chart.sh`:

```bash
#!/bin/bash
set -e

CHART_DIR="./mychart"
OCI_REGISTRY="oci://ghcr.io/myorg/charts"  # Use a real registry

echo "=== Logging in to registry ==="
helm registry login ghcr.io --username "$GITHUB_USER" --password "$GITHUB_TOKEN"

echo "=== Packaging chart ==="
helm package "$CHART_DIR"

echo "=== Pushing chart to OCI registry ==="
helm push mychart-0.1.0.tgz "$OCI_REGISTRY"
```
