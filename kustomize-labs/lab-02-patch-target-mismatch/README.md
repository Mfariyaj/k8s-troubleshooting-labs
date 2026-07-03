## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh`
2. Observe the error output
3. Diagnose the root cause
4. Apply the fix
5. Verify it works. Check `solution.md` if stuck

---

# Patch Target Mismatch

## Difficulty: ⭐⭐ Medium

## 📚 What This Teaches
A strategic merge patch doesn't apply because the target resource name or kind doesn't match any resource in the base.

## 🔧 Scenario
A strategic merge patch doesn't apply because the target resource name or kind doesn't match any resource in the base.

## 💥 Error Output
```
Error: no matches for Id Deployment.apps/wrong-name; failed to find unique target for patch
```

## 💡 Hints

<details><summary>Hint 1</summary>
Compare the patch metadata (name, kind) with the resources in base/
</details>

<details><summary>Hint 2</summary>
The patch must have EXACT same apiVersion, kind, and metadata.name as the target resource
</details>

<details><summary>Hint 3</summary>
Fix the name/kind in the patch file to match the actual resource in base/deployment.yaml
</details>

## 🛠️ Useful Commands
```bash
kustomize build .
cat patches/my-patch.yaml   # Check target name
cat base/deployment.yaml    # Check actual name
diff <(grep 'name:' patches/my-patch.yaml) <(grep 'name:' base/deployment.yaml)
```
