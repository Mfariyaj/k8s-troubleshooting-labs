## Solution: Patch Target Mismatch

### Root Cause
A strategic merge patch doesn't apply because the target resource name or kind doesn't match any resource in the base.

### Fix
Fix the name/kind in the patch file to match the actual resource in base/deployment.yaml

### Verification
Run the commands below to verify the fix works:
```bash
kustomize build .
cat patches/my-patch.yaml   # Check target name
cat base/deployment.yaml    # Check actual name
diff <(grep 'name:' patches/my-patch.yaml) <(grep 'name:' base/deployment.yaml)
```
