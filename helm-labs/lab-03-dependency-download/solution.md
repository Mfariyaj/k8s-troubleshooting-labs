# Lab 03 - Dependency Download Failure

## Root Cause

The `Chart.yaml` dependencies section has two issues:
1. The Bitnami repository URL has a typo (e.g., `https://charts.bitmani.com/bitnami`
   instead of `https://charts.bitnami.com/bitnami`)
2. The specified chart version does not exist in the repository

## Symptoms

- `helm dependency update` fails with "repo not found" or 404 errors
- `helm dependency build` reports "no matching version"
- `charts/` directory is empty, missing required subchart tarballs

## Fix Steps

1. Open `mychart/Chart.yaml`
2. Fix the repository URL typo to `https://charts.bitnami.com/bitnami`
3. Change the version to an existing version of the chart

## Corrected Configuration

```yaml
apiVersion: v2
name: mychart
version: 0.1.0
dependencies:
  - name: postgresql
    version: "12.5.8"
    repository: "https://charts.bitnami.com/bitnami"
```

## Fix Commands

```bash
# Add the correct repo
helm repo add bitnami https://charts.bitnami.com/bitnami

# Search for available versions
helm search repo bitnami/postgresql --versions | head -10

# Update dependencies
cd mychart
helm dependency update
```

## Verification

```bash
# Verify dependency downloaded
ls mychart/charts/

# Lint the chart with dependencies
helm lint ./mychart

# Template to ensure subchart renders
helm template myapp ./mychart
```

## Key Takeaways

- Always verify repo URLs with `helm repo add` before using in Chart.yaml
- Use `helm search repo <chart> --versions` to find valid versions
- Run `helm dependency update` after fixing Chart.yaml
- Check `Chart.lock` for the resolved dependency versions
