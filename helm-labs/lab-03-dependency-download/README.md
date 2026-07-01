# Lab 03: Dependency Download Failure

## Difficulty: ⭐⭐ Medium

## Scenario

A developer is trying to build a Helm chart that depends on Bitnami's PostgreSQL chart. When they run `helm dependency update`, it fails. There are TWO issues:
1. The repository URL has a typo (`bitnmi` instead of `bitnami`)
2. The version `99.0.0` doesn't exist in the Bitnami repository

Your task: Fix the Chart.yaml dependencies so `helm dependency update` succeeds.

## Error Output

```
$ helm dependency update ./mychart
Hang tight while we grab the latest from your chart repositories...
...Unable to get an update from the "https://charts.bitnami.com/bitnmi" chart repository:
        failed to fetch https://charts.bitnami.com/bitnmi/index.yaml : 404 Not Found
Save error occurred:  could not download https://charts.bitnami.com/bitnmi/index.yaml
Error: no repository definition for https://charts.bitnami.com/bitnmi. Please add the missing repos via 'helm repo add'

$ helm dependency build ./mychart
Error: the lock file (Chart.lock) is out of sync with the dependencies file (Chart.yaml). Please update the dependencies file to get the lock file in sync.
```

## Hints

1. Look carefully at the repository URL — compare `bitnmi` vs `bitnami`. It's a subtle typo.
2. Check available PostgreSQL chart versions with `helm search repo bitnami/postgresql --versions` after adding the correct repo.
3. After fixing Chart.yaml, delete Chart.lock and run `helm dependency update` to regenerate it.

## Commands

```bash
# Show the dependency error
helm dependency update ./mychart

# After fixing, add the repo and update
helm repo add bitnami https://charts.bitnami.com/bitnami
helm search repo bitnami/postgresql --versions | head -10
helm dependency update ./mychart
```

## Root Cause

Two issues in Chart.yaml dependencies:
1. Repository URL typo: `https://charts.bitnami.com/bitnmi` should be `https://charts.bitnami.com/bitnami`
2. Version `99.0.0` does not exist — use a real version like `12.x.x` or use a version constraint like `>=12.0.0`

## Fix

```yaml
dependencies:
  - name: postgresql
    version: "12.12.10"    # Use a real version
    repository: "https://charts.bitnami.com/bitnami"  # Fix typo: bitnmi -> bitnami
```

Then delete Chart.lock and run:
```bash
rm mychart/Chart.lock
helm dependency update ./mychart
```
