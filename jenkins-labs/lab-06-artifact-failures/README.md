## 🎯 How to Use This Lab

1. Start Jenkins: `./deploy.sh` (or use an already-running Jenkins instance)
2. Open **http://localhost:8080** → **New Item** → **Pipeline**
3. Paste the `Jenkinsfile` contents into "Pipeline script"
4. Click **Save** → **Build Now**
5. Click **Console Output** on the failed build to see the error
6. Diagnose and fix! Check `solution.md` if stuck.

---

# Lab 06: Artifact Failures

## Difficulty: ⭐⭐ Medium

## Scenario

A pipeline builds an application and tries to archive artifacts, but uses wrong glob patterns and attempts to stash files that exceed the size limit.

## Console Error Output

```
[Pipeline] archiveArtifacts
ERROR: No artifacts found that match the file pattern "dist/**/*.jar". 
Configuration error?
[Pipeline] stash
ERROR: Stash 'build-artifacts' exceeds the maximum allowed size.
java.io.IOException: Stash exceeds maximum size of 104857600 bytes (actual: 524288000)
    at org.jenkinsci.plugins.workflow.flow.StashManager.stash(...)
[Pipeline] End of Pipeline
ERROR: script returned exit code 1
```

## Hints

1. Check where the build actually outputs files (hint: it's `build/output/`, not `dist/`)
2. The `archiveArtifacts` glob must match the actual file path relative to workspace
3. Stash has a default size limit (~100MB) — don't stash large binary files
4. Use `archiveArtifacts` for large files instead of `stash`

## What to Fix

- Fix glob: change `dist/**/*.jar` to `build/output/**/*.jar`
- Remove large binary from stash, or exclude it: `includes: 'build/output/**', excludes: '**/*.bin'`
- Alternatively, don't generate the oversized file
