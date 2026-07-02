## 🎯 How to Use This Lab

1. Start Jenkins: `./deploy.sh` (or use an already-running Jenkins instance)
2. Open **http://localhost:8080** → **New Item** → **Pipeline**
3. Paste the `Jenkinsfile` contents into "Pipeline script"
4. Click **Save** → **Build Now**
5. Click **Console Output** on the failed build to see the error
6. Diagnose and fix! Check `solution.md` if stuck.

---

# Lab 04: Shared Library

## Difficulty: ⭐⭐ Medium

## Scenario

A pipeline references a shared library, but the library name in `@Library` doesn't match what's configured in Jenkins Global Configuration. The library code exists but Jenkins can't find it.

## Console Error Output

```
ERROR: Library 'wrong-name' not found
You may need to configure the library in Jenkins under
Manage Jenkins → Configure System → Global Pipeline Libraries

Available libraries: [my-shared-lib]

org.codehaus.groovy.control.MultipleCompilationErrorsException: startup failed:
WorkflowScript: 2: Library 'wrong-name' is not configured in Jenkins @ line 2, column 1.
   @Library('wrong-name') _
   ^
```

## Hints

1. Check `Manage Jenkins → Configure System → Global Pipeline Libraries`
2. The `@Library('name')` annotation must match the library name exactly (case-sensitive)
3. The library must be configured with a valid source (Git repo, local path, etc.)
4. The `vars/` directory contains the global variables available to pipelines

## What to Fix

- Change `@Library('wrong-name')` to `@Library('my-shared-lib')` (the configured name)
- Or add a new library named `wrong-name` in Jenkins configuration
