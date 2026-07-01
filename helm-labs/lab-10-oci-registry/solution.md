# Lab 10 - OCI Registry Issues

## Root Cause

Two issues prevent pulling the chart from an OCI registry:
1. The OCI URL is malformed (e.g., wrong prefix, missing path, or typo in registry host)
2. Missing `helm registry login` command - authentication is required before pulling

## Symptoms

- `helm pull` or `helm install` fails with "failed to fetch OCI"
- Error: "unauthorized: authentication required"
- Error: "unknown host" or "invalid reference format"
- Chart cannot be resolved from the OCI registry

## Fix Steps

1. Fix the OCI URL to use correct format: `oci://registry-host/path/chart-name`
2. Run `helm registry login` before pulling/installing

## Corrected Commands

```bash
# Step 1: Login to the OCI registry
helm registry login registry.example.com \
  --username myuser \
  --password mypassword

# Step 2: Pull with correct OCI URL format
helm pull oci://registry.example.com/helm-charts/mychart --version 1.0.0

# Or install directly
helm install myapp oci://registry.example.com/helm-charts/mychart --version 1.0.0
```

For local registries (e.g., running in Docker):
```bash
# Login to local registry
helm registry login localhost:5000 --insecure

# Push a chart
helm push mychart-0.1.0.tgz oci://localhost:5000/helm-charts

# Pull/install from local registry
helm install myapp oci://localhost:5000/helm-charts/mychart --version 0.1.0
```

## Verification

```bash
# Verify login succeeded
helm registry login registry.example.com --username myuser --password mypassword

# List tags in the registry (if supported)
helm show chart oci://registry.example.com/helm-charts/mychart --version 1.0.0

# Successful install
helm install myapp oci://registry.example.com/helm-charts/mychart --version 1.0.0
helm list | grep myapp
```

## Key Takeaways

- OCI URLs use `oci://` prefix (no `https://`)
- Authentication is required before pull/push operations
- Version must be specified with `--version` for OCI charts
- Use `--insecure` flag for registries without TLS
- OCI chart references do not include the tag in the URL (use `--version` flag)
