## 🎯 How to Use This Lab

1. Start Jenkins: `./deploy.sh` (or use an already-running Jenkins instance)
2. Open **http://localhost:8080** → **New Item** → **Pipeline**
3. Paste the `Jenkinsfile` contents into "Pipeline script"
4. Click **Save** → **Build Now**
5. Click **Console Output** on the failed build to see the error
6. Diagnose and fix! Check `solution.md` if stuck.

---

# Lab 05: Parallel Stages

## Difficulty: ⭐⭐ Medium

## Scenario

A pipeline runs unit, integration, and E2E tests in parallel. The final report stage shows corrupted or incomplete results because all parallel stages write to the same file in a shared workspace.

## Console Error Output

```
[Pipeline] parallel
[Pipeline] { (Unit Tests)
[Pipeline] { (Integration Tests)  
[Pipeline] { (E2E Tests)
[Pipeline] sh
+ echo 'UNIT TEST RESULTS' > test-results.txt
+ echo 'INTEGRATION TEST RESULTS' > test-results.txt
+ echo 'E2E TEST RESULTS' > test-results.txt
...
[Pipeline] sh (Report)
+ cat test-results.txt
E2E TEST RESULTS
e2e: PASS

ERROR: Unit test and integration test results are missing from report!
```

## Hints

1. Parallel stages on the same agent share the same workspace directory
2. Use `ws()` to allocate a unique workspace per parallel branch
3. Alternatively, use unique file names per stage (e.g., `test-results-unit.txt`)
4. Consider using `stash`/`unstash` to collect results from separate workspaces

## What to Fix

- Wrap each parallel stage's steps in `ws("unique-dir-${stageName}")` blocks
- Or use distinct file names per stage and merge in the Report stage
- Or assign separate agents per parallel branch
