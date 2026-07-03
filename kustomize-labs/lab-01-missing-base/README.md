## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh`
2. Observe the error output
3. Diagnose the root cause
4. Apply the fix
5. Verify it works. Check `solution.md` if stuck

---

# Missing Base Directory

## Difficulty: ⭐⭐ Medium

## 📚 What This Teaches
Kustomize build fails because the base directory referenced in kustomization.yaml doesn't exist. Path typo or directory moved.

## 🔧 Scenario
Kustomize build fails because the base directory referenced in kustomization.yaml doesn't exist. Path typo or directory moved.

## 💥 Error Output
```
Error: accumulating resources: accumulation err='accumulating resources from '../base': read /path/to/base: no such file or directory'
```

## 💡 Hints

<details><summary>Hint 1</summary>
Check the 'resources:' field in kustomization.yaml — what path does it reference?
</details>

<details><summary>Hint 2</summary>
Run 'ls' to see available directories. The base path is relative to kustomization.yaml location.
</details>

<details><summary>Hint 3</summary>
Fix the path in kustomization.yaml to point to the correct base directory. Use relative paths.
</details>

## 🛠️ Useful Commands
```bash
kustomize build .
cat kustomization.yaml
ls -la ../   # Check if base exists
kustomize build . --enable-alpha-plugins 2>&1 | head -20
```
