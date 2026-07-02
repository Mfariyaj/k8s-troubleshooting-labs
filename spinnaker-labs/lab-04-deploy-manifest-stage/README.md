## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (copies broken config to workspace)
2. Upload pipeline: `spin pipeline save --file pipeline.json`
3. Execute: `spin pipeline execute --name <pipeline> --application <app>`
4. Check Spinnaker UI for execution errors
5. Fix the pipeline JSON or service config
6. Check `solution.md` if stuck

---

# Lab 04: Deploy Manifest Stage — Artifact Binding Failure

## Difficulty: 🟡 Intermediate

---

## 📚 What You'll Learn

The **Deploy (Manifest)** stage is the primary way Spinnaker deploys to Kubernetes. It can consume manifests from:

- **Inline text** — YAML pasted directly into the stage
- **Artifacts** — References to manifests stored in Git, S3, GCS, or HTTP endpoints
- **Produced artifacts** — Manifests output from a previous stage (Bake Manifest with Helm/Kustomize)

Key concepts:
- **Artifact binding**: Linking a manifest source to expected artifacts in the pipeline
- **requiredArtifactIds**: Tells the stage which artifacts it MUST receive to execute
- **Expected Artifacts**: Defined at pipeline level, matched by type + reference
- **Default Artifacts**: Fallback when no matching artifact is found in the trigger

When artifact binding fails, Spinnaker either can't find the manifest to deploy, or substitutes the wrong artifact. This is one of the most confusing aspects of Spinnaker for new users.

---

## 🔧 Scenario

A pipeline uses an external manifest (from a GitHub artifact) in its Deploy Manifest stage. The deployment fails because:

1. The `requiredArtifactIds` references an artifact ID that doesn't exist in the pipeline's expected artifacts
2. The expected artifact `reference` path doesn't match the actual file path in the repository
3. The namespace specified in the stage doesn't exist in the cluster

---

## 💥 Expected Error Output

In Spinnaker UI (Stage execution details):
```
Exception: Manifest deployment failed
Stage: Deploy to Production

Error details:
  - Could not find required artifact with id 
    'artifact-abc123-deploy-manifest' in pipeline context.
    Available artifacts: [artifact-xyz789-github-file]
    
  - Artifact resolution failed: No artifact could be resolved for 
    expected artifact: {type: github/file, reference: 
    'https://api.github.com/repos/myorg/myapp/contents/deploy/k8s/deployment.yml'}
    
  - KubernetesDeployManifestOperation: namespace 'production-ns' 
    not found in account 'my-k8s-account'
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>
Compare the `requiredArtifactIds` in the Deploy Manifest stage with the `id` fields in the pipeline's `expectedArtifacts` array. They must match exactly.
</details>

<details>
<summary>Hint 2 (Moderate)</summary>
The GitHub artifact reference path in `expectedArtifacts` is `deploy/k8s/deployment.yml` but the actual file in the repo is at `k8s/deployment.yaml` (different directory structure and extension .yaml vs .yml).
</details>

<details>
<summary>Hint 3 (Strong)</summary>
Three fixes: 1) Change `requiredArtifactIds` from `artifact-abc123-deploy-manifest` to `artifact-xyz789-github-file` to match the actual expected artifact ID, 2) Fix the reference path to match the real file location, 3) Create the `production-ns` namespace or change the override namespace to an existing one.
</details>

---

## 🛠️ Useful Commands

```bash
# Inspect pipeline configuration
spin pipeline get --name "Deploy Production" --application myapp | jq '.expectedArtifacts'
spin pipeline get --name "Deploy Production" --application myapp | jq '.stages[].requiredArtifactIds'

# Check available namespaces
kubectl get namespaces

# Check Orca logs for artifact resolution
kubectl logs -n spinnaker spin-orca-xxx | grep -i "artifact"

# View artifact accounts configured
hal config artifact github account list

# Test GitHub artifact accessibility
curl -H "Authorization: token <TOKEN>" \
  https://api.github.com/repos/myorg/myapp/contents/k8s/deployment.yaml
```

---

## 📖 References

- https://spinnaker.io/docs/reference/artifacts/
- https://spinnaker.io/docs/reference/artifacts/in-kubernetes-v2/
- https://spinnaker.io/docs/guides/user/pipeline/triggers/artifacts/
- https://spinnaker.io/docs/reference/pipeline/stages/#deploy-manifest

---

## 🏁 Success Criteria

- Pipeline resolves the GitHub artifact successfully
- Deploy Manifest stage finds and uses the correct manifest
- Deployment is created in the correct namespace
- No artifact resolution errors in Orca logs
