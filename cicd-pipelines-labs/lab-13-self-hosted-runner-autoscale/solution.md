# Solution: Lab 13 - Self-Hosted Runner Autoscaling

## Problem

Self-hosted runner pods fail to pick up jobs, Docker-in-Docker (DinD) builds fail
with permission errors, and runners don't scale properly.

## Diagnosis

```bash
# Check runner pod status
kubectl get pods -n actions-runner

# Check runner logs
kubectl logs -n actions-runner <runner-pod>

# Check DinD sidecar
kubectl logs -n actions-runner <runner-pod> -c dind

# Look for:
# - Runner label mismatch
# - Non-ephemeral runners holding stale state
# - DinD container missing privileged security context
```

## Root Cause

1. **Wrong runner label**: Workflow uses `runs-on: self-hosted-linux` but runner
   registers with label `self-hosted`. Labels must match exactly.
2. **Non-ephemeral runners**: Runners keep state between jobs, causing conflicts.
   Ephemeral runners terminate after one job and are replaced fresh.
3. **DinD security context**: Docker-in-Docker sidecar requires `privileged: true`
   to function, but the security context is missing or incorrect.

## Fix

### Step 1: Fix runner label in workflow

```yaml
jobs:
  build:
    # FIXED: Match actual runner label
    # BROKEN: runs-on: self-hosted-linux
    runs-on: [self-hosted, linux]
```

### Step 2: Make runner ephemeral

```yaml
# runner-deployment.yaml
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
        - name: runner
          env:
            - name: RUNNER_EPHEMERAL
              # FIXED: Enable ephemeral mode
              value: "true"
            - name: RUNNER_LABELS
              value: "self-hosted,linux"
```

### Step 3: Fix DinD security context

```yaml
# runner-deployment.yaml
containers:
  - name: dind
    image: docker:dind
    # FIXED: DinD requires privileged mode
    securityContext:
      privileged: true
    volumeMounts:
      - name: docker-socket
        mountPath: /var/run/docker.sock
```

## Verification

```bash
# Runner registers with correct labels
kubectl logs -n actions-runner <pod> | grep "registered"

# DinD starts successfully
kubectl logs -n actions-runner <pod> -c dind | grep "API listen"

# Workflow picks up the runner
# Check GitHub Settings → Actions → Runners shows runner as "Idle"

# Test ephemeral behavior
# After one job, pod terminates and new one spawns
kubectl get pods -n actions-runner -w
```

## Key Takeaways

- Runner labels must exactly match `runs-on:` in workflows
- Ephemeral runners prevent state leakage between jobs
- DinD requires `privileged: true` — consider alternatives like kaniko
- Use runner controller (actions-runner-controller) for proper autoscaling
