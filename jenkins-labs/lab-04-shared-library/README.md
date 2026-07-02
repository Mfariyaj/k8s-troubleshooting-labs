## 🎯 How to Use This Lab

1. Start Jenkins: `./deploy.sh` (or use an already-running Jenkins instance)
2. **Configure a Shared Library in Jenkins first** (see setup below)
3. Open **http://localhost:8080** → **New Item** → **Pipeline**
4. Paste the `Jenkinsfile` contents into "Pipeline script"
5. Click **Save** → **Build Now**
6. Click **Console Output** on the failed build to see the error
7. Diagnose and fix! Check `solution.md` if stuck.

---

## ⚙️ Jenkins Setup Required (Before Running This Lab)

### Step 1: Configure Global Pipeline Library

1. Go to **Manage Jenkins** → **System**
2. Scroll down to **"Global Trusted Pipeline Libraries"**
3. Click **"Add"**
4. Fill in:

| Field | Value |
|-------|-------|
| **Name** | `my-shared-lib` |
| **Default version** | `main` |
| **Allow default version to be overridden** | ✅ Checked |
| **Include @Library changes in job recent changes** | ✅ Checked |

5. Under **Retrieval method**, select **"Modern SCM"**
6. Under **Source Code Management**, select **"Git"**
7. Set **Project Repository**: `https://github.com/Mfariyaj/k8s-troubleshooting-labs.git`
8. Click **Save**

> **Note:** The repo doesn't need to have a real `vars/` directory for this lab.
> The point is that the Jenkinsfile uses `@Library('wrong-name')` which
> doesn't match the configured library name `my-shared-lib`.

---

## 📋 Required Plugin

- **Pipeline: Shared Groovy Libraries** (usually pre-installed with Pipeline plugin)

---

# Lab 04: Shared Library Import Failure

## Difficulty: ⭐⭐ Medium

## Scenario

A DevOps team has a shared pipeline library (`my-shared-lib`) configured in Jenkins. A developer wrote a new pipeline but used the wrong library name in the `@Library` annotation. The pipeline fails immediately at startup.

## The Broken Jenkinsfile

```groovy
@Library('wrong-name') _    // BUG: Library name doesn't match configured name

pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    buildHelper.runBuild()    // From vars/buildHelper.groovy
                }
            }
        }
    }
}
```

## Console Error Output

```
Started by user admin
[Pipeline] Start of Pipeline
[Pipeline] library
ERROR: Library 'wrong-name' not found among configured libraries: [my-shared-lib]

org.codehaus.groovy.control.MultipleCompilationErrorsException: startup failed:
WorkflowScript: 1: Library 'wrong-name' is not configured in Jenkins @ line 1, column 1.
   @Library('wrong-name') _
   ^

1 error
```

## 🐛 Bugs in This Lab

1. `@Library('wrong-name')` — Library name doesn't match configured `my-shared-lib`
2. Method `buildHelper.runBuild()` — The actual file is `vars/buildHelper.groovy` but the method name might not match
3. No version pinned — `@Library('my-shared-lib')` without `@version` can cause replay divergence

## 💡 Hints

<details>
<summary>Hint 1 (Easy)</summary>
Check what libraries are configured: Manage Jenkins → System → Global Trusted Pipeline Libraries. What's the exact name?
</details>

<details>
<summary>Hint 2 (Medium)</summary>
The @Library annotation must match EXACTLY (case-sensitive). Compare 'wrong-name' with what's in the config.
</details>

<details>
<summary>Hint 3 (Hard)</summary>
Fix: Change `@Library('wrong-name')` to `@Library('my-shared-lib')`. Also pin version: `@Library('my-shared-lib@main')` for reproducibility.
</details>

## 🛠️ Troubleshooting Commands

```bash
# Check configured libraries from Script Console (Manage Jenkins → Script Console):
println(org.jenkinsci.plugins.workflow.libs.GlobalLibraries.get().libraries*.name)

# Check library resolution in pipeline log
# Look for: "Loading library my-shared-lib@main"

# Validate library repo has correct structure:
# vars/buildHelper.groovy       ← Global variables
# src/org/company/Utils.groovy  ← Classes
# resources/config.json         ← Resources
```

## 📖 Reference

- [Shared Libraries docs](https://www.jenkins.io/doc/book/pipeline/shared-libraries/)
- [Pipeline: Shared Groovy Libraries plugin](https://plugins.jenkins.io/pipeline-groovy-lib/)

## 📁 Files

| File | Purpose |
|------|---------|
| `Jenkinsfile` | Broken pipeline with wrong library name |
| `vars/buildHelper.groovy` | Example library code (what it should call) |
| `solution.md` | Full fix explanation |
