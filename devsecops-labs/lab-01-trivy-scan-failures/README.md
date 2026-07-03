## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh`
2. Observe the error output
3. Diagnose the root cause
4. Apply the fix
5. Verify it works. Check `solution.md` if stuck

---

# Trivy Container Image Scan Failing

## Difficulty: ⭐⭐ Medium

## 📚 What This Teaches
Trivy container vulnerability scanner can't scan the image. Database not downloaded, wrong image reference, or scan timeout.

## 🔧 Scenario
Trivy container vulnerability scanner can't scan the image. Database not downloaded, wrong image reference, or scan timeout.

## 💥 Error Output
```
FATAL unable to initialize a scanner: unable to initialize a vulnerability DB: error in DB initialization: failed to download vulnerability DB
2024-01-15T10:30:00.000Z FATAL failed to initialize DB: fail to open DB: no such file or directory
```

## 💡 Hints

<details><summary>Hint 1</summary>
Check if trivy can access the internet to download its vulnerability database
</details>

<details><summary>Hint 2</summary>
Try: trivy image --download-db-only (downloads DB first). Or use --skip-db-update with a pre-cached DB.
</details>

<details><summary>Hint 3</summary>
Download the DB first with 'trivy --download-db-only', or set TRIVY_DB_REPOSITORY for air-gapped environments. Check the image name is correct.
</details>

## 🛠️ Useful Commands
```bash
trivy image --download-db-only
trivy image nginx:latest
trivy image --severity HIGH,CRITICAL nginx:latest
trivy image --ignore-unfixed nginx:latest
trivy fs --security-checks vuln,config .
```
