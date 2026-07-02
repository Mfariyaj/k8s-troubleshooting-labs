## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (runs helm template/install showing error)
2. Read the Helm error output carefully
3. Check Chart.yaml, values.yaml, and templates/ for issues
4. Fix the chart and re-run `helm template` or `helm install --dry-run`
5. Verify the rendered YAML is correct
6. Check `solution.md` if stuck

---

# Lab 11: Helm Post-Renderer with Kustomize Fails

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your team uses Helm post-renderers to apply Kustomize patches on top of Helm-rendered manifests. This allows injecting sidecars, modifying resource limits, and adding labels that aren't supported by the chart's values.yaml. After a recent CI/CD pipeline migration, the post-renderer integration is completely broken — Kustomize patches don't apply, resource names don't match, and the YAML output is corrupted.

## What You'll Observe

When you run `helm install` or `helm template` with the post-renderer:

```
$ helm install myapp ./mychart --post-renderer ./post-render.sh
Error: plugin "post-render.sh" exited with error: fork/exec ./post-render.sh: permission denied

$ chmod +x post-render.sh && helm install myapp ./mychart --post-renderer ./post-render.sh
Error: plugin "post-render.sh" exited with error: exit status 1
stderr: /usr/local/bin/kustomize: No such file or directory

$ # After fixing PATH issues:
Error: plugin "post-render.sh" exited with error: exit status 1
stderr: Error: no matches for OriginalId apps/v1beta1.Deployment.[noNs].myapp-deployment; no matches for CurrentId apps/v1beta1.Deployment.[noNs].myapp-deployment

$ # After fixing apiVersion:
Error: plugin "post-render.sh" exited with error: exit status 1
stderr: Error: no matches for OriginalId apps/v1.Deployment.[noNs].myapp-deployment; no matches for CurrentId apps/v1.Deployment.[noNs].myapp-deployment

$ # Output YAML is empty or corrupted with cat binary output mixed in
```

## Your Task

Fix all issues with the post-renderer pipeline so that:
1. The post-render.sh script executes correctly
2. Kustomize patches apply to the Helm-rendered output
3. The final YAML is valid and includes the patched resources

## Hints

<details>
<summary>Hint 1</summary>
The post-render script must read from stdin and write to stdout. Check how the script handles piping — is it writing the Helm output to a file for Kustomize to read, or is it using stdin/stdout incorrectly? Also check what binary path is being used for kustomize.
</details>

<details>
<summary>Hint 2</summary>
Kustomize patches target resources by name, kind, group, and version. The name in the kustomization.yaml `resources` section and in patches must exactly match what Helm renders. Run `helm template` to see the actual resource names and apiVersions produced by the chart.
</details>

<details>
<summary>Hint 3</summary>
The kustomization.yaml `resources` field expects files, but in a post-renderer workflow, stdin is used. Check if the script writes stdin to a temporary file that kustomization.yaml references. Also verify the patch target uses `apps/v1` not `apps/v1beta1`, and that the resource name matches the Helm template output exactly (including release name prefix).
</details>

## Commands to Help Diagnose

```bash
# Test post-renderer manually
helm template myapp ./mychart | ./post-render.sh

# Check script permissions
ls -la post-render.sh
file post-render.sh

# Debug post-renderer step by step
helm template myapp ./mychart > /tmp/helm-output.yaml
cat /tmp/helm-output.yaml | ./post-render.sh

# Check what Helm actually renders
helm template myapp ./mychart

# Validate kustomize independently
cp /tmp/helm-output.yaml kustomize/all.yaml
cd kustomize && kustomize build .

# Check kustomize version and path
which kustomize
kustomize version

# Inspect patch targets
cat kustomize/patches/resource-patch.yaml

# Check for Windows line endings in script
cat -A post-render.sh
file post-render.sh

# Debug with verbose output
bash -x post-render.sh < /tmp/helm-output.yaml

# Check kustomization.yaml resources reference
cat kustomize/kustomization.yaml
```

## What You'll Learn

- How Helm post-renderers work (stdin/stdout contract)
- Integrating Kustomize as a post-renderer
- Resource targeting in Kustomize strategic merge patches
- Debugging shell script piping issues
- Understanding the relationship between Helm release names and Kustomize resource references
