## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (runs helm template/install showing error)
2. Read the Helm error output carefully
3. Check Chart.yaml, values.yaml, and templates/ for issues
4. Fix the chart and re-run `helm template` or `helm install --dry-run`
5. Verify the rendered YAML is correct
6. Check `solution.md` if stuck

---

# Lab 01: Values Override Precedence

## Difficulty: ⭐ Easy

## Scenario

A developer deployed a Helm chart using a custom values file (`custom-values.yaml`) that sets `replicaCount: 3`. However, they also used `--set replicaCount=5` on the command line. They expected 3 replicas (from the file) but got 5. They are confused about why the file values are being ignored.

Your task: Understand the Helm values override precedence and explain why `--set` wins over `-f`.

## Error / Unexpected Behavior

```
$ helm template myrelease ./mychart -f custom-values.yaml --set replicaCount=5 --debug
---
# Source: mychart/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myrelease-mychart
  labels:
    app: myrelease-mychart
spec:
  replicas: 5          # <-- Expected 3 from custom-values.yaml, got 5!
  selector:
    matchLabels:
      app: myrelease-mychart
  template:
    metadata:
      labels:
        app: myrelease-mychart
    spec:
      containers:
        - name: nginx
          image: "nginx:1.23"
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 80
```

## Hints

1. Helm has a specific precedence order for values: default values.yaml < parent chart values < -f file < --set flags
2. The `--set` flag always takes highest priority and overrides everything else
3. If you want the file to win, remove the `--set` flag or don't pass conflicting keys via `--set`

## Commands

```bash
# Show the values precedence issue
helm template myrelease ./mychart -f custom-values.yaml --set replicaCount=5 --debug

# Correct: use only the values file
helm template myrelease ./mychart -f custom-values.yaml --debug

# Correct: use only --set
helm template myrelease ./mychart --set replicaCount=5 --debug
```

## Root Cause

Helm values override precedence (lowest to highest):
1. `values.yaml` (chart defaults)
2. Parent chart's `values.yaml`
3. `-f` / `--values` file
4. `--set` flags

`--set replicaCount=5` always overrides `-f custom-values.yaml` because `--set` has higher precedence.

## Fix

Remove the conflicting `--set` flag if you want the values file to take effect:
```bash
helm install myrelease ./mychart -f custom-values.yaml
```
