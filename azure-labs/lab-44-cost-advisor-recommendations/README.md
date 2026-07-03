## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh`
2. Open Azure Portal: https://portal.azure.com
3. Navigate to the resource and observe the error
4. Fix using Portal or CLI
5. Check `solution.md` if stuck. Cleanup: `./cleanup.sh`

---

# Lab 44: cost advisor recommendations

## Category: Cost
## Cost: FREE
## Difficulty: ⭐⭐ Medium

## 📚 What This Teaches
Azure Advisor showing 00/month savings ignored

## 🔧 Scenario
Azure Advisor showing 00/month savings ignored

## 💥 Expected Error
```
Azure Advisor showing 00/month savings ignored
```

## 💡 Hints

<details><summary>Hint 1</summary>
Check the Azure Portal for the resource. Look at the error message in Activity Log.
</details>

<details><summary>Hint 2</summary>
Run: az advisor recommendation list
</details>

<details><summary>Hint 3</summary>
Check solution.md for the exact fix.
</details>

## 🛠️ Useful Commands
```bash
# Azure CLI:
az advisor recommendation list

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
