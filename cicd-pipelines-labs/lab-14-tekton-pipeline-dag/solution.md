# Solution: Lab 14 - Tekton Pipeline DAG Issues

## Problem

Tekton pipeline tasks fail to execute in the correct order, workspace volumes fail
to mount across tasks, and task results aren't propagated.

## Diagnosis

```bash
# Check pipeline run status
kubectl get pipelinerun -n tekton-pipelines
kubectl describe pipelinerun <name> -n tekton-pipelines

# Check individual task runs
kubectl get taskrun -n tekton-pipelines
kubectl logs -n tekton-pipelines <taskrun-pod>

# Look for:
# - "task not found" in runAfter references
# - PVC access mode issues (ReadWriteOnce vs ReadWriteMany)
# - Results name mismatch
```

## Root Cause

1. **Wrong `runAfter` task name**: The `runAfter` field references a task name that
   doesn't match the actual task name in the pipeline definition.
2. **PVC access mode**: Multiple tasks need concurrent access to the workspace, but
   the PVC is `ReadWriteOnce` — only one pod can mount it at a time.
3. **Results name mismatch**: A downstream task references a result by the wrong
   name, causing substitution to fail.

## Fix

### Step 1: Fix runAfter task name

```yaml
# pipeline.yaml
spec:
  tasks:
    - name: build
      taskRef:
        name: build-task
    - name: test
      # BROKEN: runAfter: [build-step]  # Wrong name!
      # FIXED: Must match the task name in this pipeline
      runAfter: [build]
      taskRef:
        name: test-task
```

### Step 2: Use ReadWriteMany PVC

```yaml
# PVC for workspace
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pipeline-workspace
spec:
  # BROKEN: accessModes: [ReadWriteOnce]
  # FIXED: Allow multiple pods to mount simultaneously
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
```

### Step 3: Fix results name

```yaml
# In the pipeline, reference results correctly
tasks:
  - name: deploy
    runAfter: [build]
    params:
      - name: image-digest
        # BROKEN: value: $(tasks.build.results.IMAGE_DIGEST)
        # FIXED: Match the exact result name from the task definition
        value: $(tasks.build.results.image-digest)
```

## Verification

```bash
# Run the pipeline
kubectl create -f pipelinerun.yaml

# Watch execution order
kubectl get taskrun -n tekton-pipelines -w

# Verify all tasks complete
kubectl get pipelinerun <name> -o jsonpath='{.status.conditions[0].status}'

# Check results propagation
kubectl get taskrun <build-taskrun> -o jsonpath='{.status.taskResults}'
```

## Key Takeaways

- `runAfter` uses the pipeline task name (not the TaskRef name)
- Use `ReadWriteMany` PVCs when parallel tasks share a workspace
- Result names are case-sensitive and hyphen-sensitive
- Use `kubectl describe pipelinerun` to see exactly which task failed and why
