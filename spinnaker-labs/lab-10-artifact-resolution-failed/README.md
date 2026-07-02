## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (copies broken config to workspace)
2. Upload pipeline: `spin pipeline save --file pipeline.json`
3. Execute: `spin pipeline execute --name <pipeline> --application <app>`
4. Check Spinnaker UI for execution errors
5. Fix the pipeline JSON or service config
6. Check `solution.md` if stuck

---

# Lab 10: Artifact Resolution Failed — Can't Find or Bind Artifacts

## Difficulty: 🟡 Intermediate

---

## 📚 What You'll Learn

Spinnaker's **artifact system** manages versioned resources (Docker images, files, Helm charts) flowing through pipelines. Understanding how artifacts work is essential for any non-trivial pipeline.

Key concepts:
- **Expected Artifacts**: What the pipeline expects to receive (defined at pipeline level)
- **Received Artifacts**: What actually arrives via triggers/stages (at runtime)
- **Matching**: Spinnaker matches received artifacts to expected artifacts by type + reference
- **Default Artifacts**: Fallback when no matching artifact arrives
- **Bound Artifacts**: An expected artifact that successfully matched a received one

Artifact types:
- `docker/image` — Docker container images (e.g., `myorg/myapp:v1.2.3`)
- `github/file` — Files from GitHub repos
- `s3/object` — Files in S3 buckets
- `embedded/base64` — Inline content encoded as base64
- `helm/chart` — Helm chart packages
- `http/file` — Files at HTTP URLs

Common failures:
- `type` mismatch between expected and received artifact
- `reference` pattern doesn't match incoming artifact reference
- Default artifact misconfigured (wrong type or reference)
- `useDefaultArtifact: false` with no matching artifact → resolution fails
- Artifact account not configured in Clouddriver/Igor

---

## 🔧 Scenario

A pipeline that deploys a Docker image and a Kubernetes manifest from GitHub fails because:

1. Expected artifact type is `docker/image` but the trigger produces `Docker/Image` (case mismatch)
2. The GitHub file artifact reference uses `master` branch but the repo default is now `main`
3. Default artifact has `useDefaultArtifact: true` but the `defaultArtifact` object is empty (no reference/type)

---

## 💥 Expected Error Output

```
Exception: Could not resolve artifacts
Stage: Bind Artifacts

Errors:
  - Failed to find artifact matching expected artifact:
    {type: docker/image, name: myorg/myapp}
    Received artifacts: [{type: Docker/Image, name: myorg/myapp, 
    reference: myorg/myapp:release-1.0.0}]
    
  - Could not fetch artifact from GitHub:
    https://api.github.com/repos/myorg/myapp/contents/k8s/deploy.yaml?ref=master
    404 Not Found: Branch 'master' does not exist (default: 'main')
    
  - Default artifact resolution failed: defaultArtifact is empty/null
    for expected artifact 'k8s-manifest'. Cannot use as fallback.
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>
Artifact type matching is case-sensitive. Compare the `type` field in expected artifacts with what triggers/stages actually produce. Docker triggers produce `docker/image` (lowercase).
</details>

<details>
<summary>Hint 2 (Moderate)</summary>
Many repos migrated default branches from `master` to `main`. The artifact `version` or `ref` field determines which branch to fetch from. Update any `master` references.
</details>

<details>
<summary>Hint 3 (Strong)</summary>
Fixes: 1) Ensure expected artifact type is exactly `docker/image` (lowercase) and the trigger/received artifact matches, 2) Change `?ref=master` to `?ref=main` in GitHub artifact reference, 3) Add proper type and reference to the defaultArtifact object.
</details>

---

## 🛠️ Useful Commands

```bash
# Inspect pipeline artifacts
spin pipeline get --name "Deploy" --application myapp | jq '.expectedArtifacts'

# Check artifact accounts
hal config artifact github account list
hal config artifact s3 account list

# View received artifacts from last execution
spin pipeline execution get --id <exec-id> | jq '.trigger.artifacts'

# Test GitHub artifact fetch
curl -H "Authorization: token <TOKEN>" \
  "https://api.github.com/repos/myorg/myapp/contents/k8s/deploy.yaml?ref=main"

# Check Clouddriver artifact resolution
kubectl logs -n spinnaker spin-clouddriver-xxx | grep -i "artifact"
```

---

## 📖 References

- https://spinnaker.io/docs/reference/artifacts/
- https://spinnaker.io/docs/reference/artifacts/types/
- https://spinnaker.io/docs/guides/user/pipeline/triggers/artifacts/
- https://spinnaker.io/docs/reference/artifacts/in-pipelines/

---

## 🏁 Success Criteria

- Docker image artifact resolves correctly from trigger
- GitHub file artifact fetches successfully
- Default artifacts work as fallback when trigger doesn't provide artifact
- Pipeline deploys using the bound artifacts
