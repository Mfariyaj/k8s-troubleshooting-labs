## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (creates a git repo with broken workflow)
2. Review the broken workflow YAML (.github/workflows/ or .gitlab-ci.yml)
3. Identify the syntax errors, logic issues, or misconfiguration
4. Fix the workflow file
5. Validate with: `actionlint` (GitHub Actions) or CI Lint API (GitLab)
6. Check `solution.md` if stuck

---

# Lab 14: Tekton Pipeline DAG — Task Ordering, Workspaces, and Results Broken

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your team has built a Tekton Pipeline for a cloud-native CI/CD system. The pipeline should:
1. Clone → Lint + Test (parallel) → Build → Security Scan → Deploy

However, the PipelineRun immediately fails with validation errors, and even after partial fixes, tasks run in wrong order, get stuck, or can't pass data between each other. The platform team is scrambling because all deployments through this pipeline are blocked.

## Error Output

```
$ tkn pipelinerun logs build-deploy-run-001 -n ci

PipelineRun ci/build-deploy-run-001 has failed:
  Error: Pipeline ci/build-deploy-pipeline can't be Run;
  it references Tasks that don't exist: "lint"
  (Task "build-image" has runAfter dependency on "lint" which does not exist in this Pipeline)
```

```
# After fixing the runAfter reference:
$ tkn pipelinerun logs build-deploy-run-001 -n ci

[code-lint] Status: Running
[unit-test] Status: Pending — waiting for PVC to become available
  Warning: Multi-Attach error for volume "pvc-abc123":
    Volume is already exclusively attached to one node
    and can't be attached to another

[build-image] invalid input result reference:
  "$(tasks.build-image.results.IMAGE_URL)" not found.
  Available results: ["image-url", "image-digest"]
```

```
# Parameter type mismatch:
PipelineRun ci/build-deploy-run-001 has failed:
  Validation error: param "deploy-targets" has type "array"
  but received value of type "string"
```

```
# Finally task workspace error (Tekton < v0.50):
Error: finally task "cleanup" has workspace "source"
  which is not allowed — finally tasks do not have access to workspaces
```

## Your Task

Identify and fix ALL Tekton Pipeline issues:
1. Fix the `runAfter` dependency that references a non-existent task
2. Fix the workspace PVC `accessMode` for parallel task execution
3. Fix the results name mismatch between tasks
4. Fix the params type mismatch (array vs string)
5. Fix or remove the `finally` task workspace access

## Hints

<details>
<summary>Hint 1</summary>
The `build-image` task has `runAfter: ["lint"]` but the actual task name in the pipeline is `code-lint`. Tekton validates all `runAfter` references at PipelineRun creation time. Fix the reference to match the actual task name. Also check the PVC: `ReadWriteOnce` means only one pod can mount it — parallel tasks on different nodes will fail.
</details>

<details>
<summary>Hint 2</summary>
The `kaniko` task declares its result as `image-url` (lowercase, hyphenated) but the pipeline references it as `$(tasks.build-image.results.IMAGE_URL)` (uppercase, underscored). Tekton result names are case-sensitive and must match exactly. Check `tasks/build-task.yaml` for the actual result name.
</details>

<details>
<summary>Hint 3</summary>
The `deploy-targets` param is declared as `type: array` in the Pipeline but the PipelineRun passes `value: "staging"` (a string). For array params, use `value: ["staging"]` syntax. Also, Tekton versions prior to v0.50 don't allow `finally` tasks to access workspaces — either upgrade Tekton or remove the workspace reference from the finally task.
</details>

## Useful Commands

```bash
# Examine pipeline definition
cat pipeline.yaml

# Examine task definitions
cat tasks/build-task.yaml
cat tasks/deploy-task.yaml
cat tasks/cleanup-task.yaml

# Examine the pipeline run
cat pipelinerun.yaml

# Apply and observe failures
kubectl apply -f tasks/ -n ci
kubectl apply -f pipeline.yaml -n ci
kubectl apply -f pipelinerun.yaml -n ci

# Check PipelineRun status
tkn pipelinerun describe build-deploy-run-001 -n ci
tkn pipelinerun logs build-deploy-run-001 -n ci

# Check task status
tkn taskrun list -n ci
tkn taskrun describe <taskrun-name> -n ci

# Check for validation errors
kubectl describe pipelinerun build-deploy-run-001 -n ci

# Check PVC status (parallel mounting issues)
kubectl get pvc -n ci
kubectl describe pvc pipeline-workspace-pvc -n ci

# Check events for scheduling issues
kubectl get events -n ci --sort-by='.lastTimestamp' | grep -i "multi-attach\|volume\|pvc"

# Validate pipeline locally
tkn pipeline verify pipeline.yaml

# List available results from a task
tkn task describe kaniko -n ci -o json | jq '.spec.results'

# Check Tekton version (important for finally task workspace support)
tkn version
kubectl get deploy -n tekton-pipelines -o jsonpath='{.items[*].spec.template.spec.containers[*].image}'
```

## What You'll Learn

- Tekton Pipeline DAG structure and `runAfter` dependencies
- Workspace sharing with PVCs and access modes (RWO vs RWX)
- Task result naming conventions and cross-task references
- Pipeline parameter types (string vs array)
- Finally task limitations and version-specific behavior
- Debugging PipelineRun validation failures
