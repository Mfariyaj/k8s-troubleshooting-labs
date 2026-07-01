## Solution: Hook Failure — PreSync Job Crash

### Root Cause
Three issues prevent the PreSync hook from succeeding:
1. The Job uses `postgres:nonexistent-version` — an invalid image tag
2. `backoffLimit: 0` means zero retries; any failure is permanent
3. The ServiceAccount `migration-runner` has no RBAC (Role/RoleBinding)

### Step-by-Step Fix

1. Identify hook failure:
   ```bash
   argocd app get hook-failure-app
   kubectl describe job pre-sync-db-migration -n hook-failure-lab
   ```
2. Fix the image tag to `postgres:15`
3. Increase `backoffLimit` to 3
4. Add a Role and RoleBinding for the ServiceAccount

### Fixed YAML — hooks/pre-sync-job.yaml
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pre-sync-db-migration
  namespace: hook-failure-lab
  annotations:
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  backoffLimit: 3
  template:
    spec:
      serviceAccountName: migration-runner
      containers:
        - name: db-migrate
          image: postgres:15
          command: ["sh", "-c", "echo 'Running DB migration' && sleep 2"]
          env:
            - name: PGPASSWORD
              value: "secretpassword"
      restartPolicy: Never
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: migration-runner
  namespace: hook-failure-lab
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: migration-runner-role
  namespace: hook-failure-lab
rules:
  - apiGroups: ["", "batch"]
    resources: ["pods", "jobs"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: migration-runner-binding
  namespace: hook-failure-lab
subjects:
  - kind: ServiceAccount
    name: migration-runner
roleRef:
  kind: Role
  name: migration-runner-role
  apiGroup: rbac.authorization.k8s.io
```

### Verification
```bash
argocd app sync hook-failure-app
argocd app wait hook-failure-app --health
kubectl get jobs -n hook-failure-lab
# Job completed successfully
```
