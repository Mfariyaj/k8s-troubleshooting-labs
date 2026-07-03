## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh`
2. Observe the error output
3. Diagnose the root cause
4. Apply the fix
5. Verify it works. Check `solution.md` if stuck

---

# lab-06-health-check-timeout

## Difficulty: ⭐⭐ Medium

## 📚 What This Teaches
Health checks timing out after apply

## 🔧 Scenario
Health checks timing out after apply

## 💥 Expected Error
When you run this lab, you should see an error related to the scenario above.
Read the error message carefully — it tells you exactly what's wrong.

## 💡 Hints

<details><summary>Hint 1 (Easy)</summary>
Read the error message carefully. What component/service is failing?
</details>

<details><summary>Hint 2 (Medium)</summary>
Check the configuration files. Is there a typo, wrong path, or missing field?
</details>

<details><summary>Hint 3 (Solution Direction)</summary>
Look at solution.md for the exact fix. The root cause is in the configuration.
</details>

## 🛠️ Useful Commands
```bash
# Check logs for errors
docker logs <container-name> 2>&1 | tail -20

# Check Kubernetes resources
kubectl get pods -A
kubectl describe pod <name> -n <namespace>
kubectl logs <pod> -n <namespace>
```
