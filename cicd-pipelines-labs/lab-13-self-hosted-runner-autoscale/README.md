# Lab 13: Self-Hosted Runner Autoscaling (ARC) — Jobs Stuck in Queue

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your organization has deployed Actions Runner Controller (ARC) on Kubernetes to provide self-hosted runners for GitHub Actions. The goal was to reduce costs by auto-scaling runners based on demand. However:

1. Workflow jobs sit in "Queued" state for 5+ minutes before being picked up
2. When runners finally start, Docker builds fail with "Cannot connect to the Docker daemon"
3. Subsequent runs on the same runner fail due to stale workspace files from previous jobs
4. The runner registration periodically fails with "401 Unauthorized"
5. Despite having 10 max replicas configured, only 1 runner ever starts

The SRE team is under pressure because the CI/CD pipeline is now slower than when they were using GitHub-hosted runners.

## Error Output

```
# GitHub Actions UI:
Job: Build Application
Status: Queued
Message: Waiting for a runner to pick up this job...
Labels: custom-runner
Duration waiting: 12m 34s

# After finally being picked up:
Step: Build Docker image
Error: Cannot connect to the Docker daemon at unix:///var/run/docker.sock
  Is the docker daemon running?

# Next run on same runner:
Step: Install dependencies
Error: ENOENT: no such file or directory, open '/runner/_work/infra-deploy/infra-deploy/package-lock.json'
  Note: package-lock.json from previous run was deleted but node_modules remains stale
```

```
# ARC Controller logs:
time="2024-03-15T10:23:45Z" level=error msg="failed to create runner"
  error="POST https://api.github.com/repos/acme-corp/infra-deploy/actions/runners/registration-token: 401 Bad credentials"

# HRA status:
$ kubectl get hra -n actions-runner-system
NAME                              MIN   MAX   DESIRED   READY
self-hosted-runner-autoscaler     0     10    0         0
```

## Your Task

Fix all issues preventing the self-hosted runners from functioning:
1. Fix the runner label mismatch between workflow and HRA
2. Fix the cold-start delay (minReplicas + scaleUpTriggers)
3. Enable ephemeral runners to prevent workspace contamination
4. Fix Docker-in-Docker configuration (volumes + security context)
5. Fix the runner authentication (don't hardcode tokens)

## Hints

<details>
<summary>Hint 1</summary>
The workflow uses `runs-on: custom-runner` but the RunnerDeployment only registers with labels `self-hosted` and `linux`. Either change the workflow to `runs-on: [self-hosted, linux]` or add `custom-runner` to the RunnerDeployment's labels list. The label must match exactly.
</details>

<details>
<summary>Hint 2</summary>
With `minReplicas: 0`, there are zero runners waiting when a job arrives. The HRA's `scaleUpTriggers` with `duration: 300s` means it takes up to 5 minutes to react. Set `minReplicas: 1` for a warm pool, or reduce the scale-up trigger duration. Also add `ephemeral: true` to the RunnerDeployment spec to ensure each job gets a fresh workspace.
</details>

<details>
<summary>Hint 3</summary>
`dockerdWithinRunnerContainer: true` requires proper volume mounts (`/var/lib/docker` with emptyDir) and a privileged security context. Without these, the Docker daemon inside the runner container cannot start. Also, never hardcode registration tokens — use a GitHub App or PAT stored in a Kubernetes Secret referenced by the controller.
</details>

## Useful Commands

```bash
# Examine the workflow
cat .github/workflows/broken-runner.yml

# Examine the ARC deployment
cat runner-deployment.yaml

# Check runner deployment status
kubectl get runnerdeployment -n actions-runner-system
kubectl get runner -n actions-runner-system
kubectl get hra -n actions-runner-system

# Check runner pods
kubectl get pods -n actions-runner-system
kubectl describe pod -n actions-runner-system -l app=self-hosted-runner

# Check ARC controller logs
kubectl logs -n actions-runner-system deployment/actions-runner-controller-controller-manager

# Check runner pod logs
kubectl logs -n actions-runner-system -l app=self-hosted-runner --tail=50

# Check if Docker daemon is running inside runner
kubectl exec -it -n actions-runner-system <runner-pod> -- docker ps

# Check runner labels
kubectl get runner -n actions-runner-system -o jsonpath='{.items[*].spec.labels}'

# Verify GitHub API access for registration
curl -H "Authorization: token $PAT" \
  https://api.github.com/repos/acme-corp/infra-deploy/actions/runners

# Check HRA scaling events
kubectl describe hra -n actions-runner-system self-hosted-runner-autoscaler

# Check events for scheduling issues
kubectl get events -n actions-runner-system --sort-by='.lastTimestamp'
```

## What You'll Learn

- Actions Runner Controller (ARC) architecture
- HorizontalRunnerAutoscaler (HRA) configuration
- Runner label matching and job routing
- Ephemeral vs persistent runner workspaces
- Docker-in-Docker (DinD) in Kubernetes pods
- Runner authentication (tokens vs GitHub Apps)
- Autoscaling triggers and cold-start optimization
