## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh`
2. Open Azure Portal: https://portal.azure.com
3. Navigate to the resource and observe the error
4. Fix using Portal or CLI
5. Check `solution.md` if stuck. Cleanup: `./cleanup.sh`

---

# Lab 06: custom role too restrictive

## Category: Identity
## Cost: FREE
## Difficulty: ⭐⭐ Medium

## 📚 What This Teaches
Custom role missing Microsoft.Compute/virtualMachines/start/action

## 🔧 Scenario
Custom role missing Microsoft.Compute/virtualMachines/start/action

## 💥 Expected Error
```
Custom role missing Microsoft.Compute/virtualMachines/start/action
```

## 💡 Hints

<details><summary>Hint 1</summary>
Check the Azure Portal for the resource. Look at the error message in Activity Log.
</details>

<details><summary>Hint 2</summary>
Run: az role definition list --custom-role-only
</details>

<details><summary>Hint 3</summary>
Check solution.md for the exact fix.
</details>

## 🛠️ Useful Commands
```bash
# Azure CLI:
az role definition list --custom-role-only

# Check activity log:
az monitor activity-log list --offset 1h -o table

# Portal: https://portal.azure.com → Resource → Activity Log
```

## 🖥️ Azure Portal Steps
1. Open https://portal.azure.com
2. Navigate to the relevant service
3. Check the configuration/errors
4. Fix the misconfiguration
5. Verify the fix works
