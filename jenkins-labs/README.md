# 🔧 Jenkins Troubleshooting Labs

## 15 Real-World Broken Jenkins Pipeline Scenarios

---

## Overview

Each lab contains an intentionally broken Jenkins pipeline or configuration. Deploy Jenkins in Docker, load the Jenkinsfile, and diagnose the failure using only the Jenkins console output and CLI tools.

---

## 🚀 How To Use These Labs (Step-by-Step)

### Step 1: Start Jenkins
```bash
cd lab-01-pipeline-syntax
./deploy.sh
```
This starts Jenkins in a Docker container at **http://localhost:8080**

### Step 2: First-Time Setup (only once)
1. Open **http://localhost:8080** in your browser
2. Paste the **initial admin password** (printed by deploy.sh)
3. Click **"Install suggested plugins"** (wait 2-3 minutes)
4. Create your admin user (or click "Skip and continue as admin")
5. Confirm the Jenkins URL → Click **"Start using Jenkins"**

### Step 3: Create a Pipeline Job
1. Click **"New Item"** on the left sidebar
2. Enter a name (e.g., `lab-01-test`)
3. Select **"Pipeline"** → Click **OK**
4. Scroll down to the **"Pipeline"** section
5. Select **"Pipeline script"** in the Definition dropdown
6. **Paste the broken Jenkinsfile** contents (from the lab directory)
7. Click **"Save"**

### Step 4: Run and Observe the Error
1. Click **"Build Now"** on the left sidebar
2. Wait for the build to fail (red ❌)
3. Click on the build number (e.g., `#1`)
4. Click **"Console Output"** to see the exact error
5. **Diagnose the issue** from the error message

### Step 5: Fix and Verify
1. Go back to the job → Click **"Configure"**
2. Fix the Jenkinsfile based on your diagnosis
3. Click **"Save"** → **"Build Now"** again
4. Build should now succeed ✅

### Step 6: Move to Next Lab
Option A: Create a **new Pipeline job** for the next lab's Jenkinsfile (same Jenkins)
Option B: Stop current Jenkins and start the next lab:
```bash
./cleanup.sh
cd ../lab-02-agent-offline
./deploy.sh
```

---

## 🔌 Required Plugins (Per Lab)

Install these plugins from **Manage Jenkins → Plugins → Available plugins**:

| Lab | Required Plugins | Why |
|-----|-----------------|-----|
| 01 | *(none — Pipeline plugin included by default)* | Basic declarative pipeline |
| 02 | *(none)* | Tests agent label matching |
| 03 | **Credentials Binding** | Uses `credentials()` helper |
| 04 | **Pipeline: Shared Groovy Libraries** | Uses `@Library` annotation |
| 05 | *(none — parallel is built-in)* | Parallel stage execution |
| 06 | *(none — archiveArtifacts is built-in)* | Artifact archiving and stash |
| 07 | **Docker Pipeline** | Uses `docker.build()` and `docker.image()` |
| 08 | **GitHub Integration**, **Git plugin** | Webhook and SCM triggers |
| 09 | **Workspace Cleanup** | Uses `cleanWs()` step |
| 10 | *(none — matrix is built-in since Jenkins 2.x)* | Matrix build configuration |
| 11 | **Configuration as Code (JCasC)** | Jenkins YAML configuration |
| 12 | **Kubernetes** | Pod template agents |
| 13 | **Pipeline: Shared Groovy Libraries** | `@Library` with version |
| 14 | **LDAP**, **Matrix Authorization Strategy** | LDAP auth + role matrix |
| 15 | *(none)* | Tests Groovy/CPS memory patterns |

### Quick Plugin Install (for all labs at once):
After Jenkins starts, go to: **Manage Jenkins → Plugins → Available plugins**

Search and install these:
- ✅ Docker Pipeline
- ✅ Credentials Binding Plugin
- ✅ Pipeline: Shared Groovy Libraries
- ✅ GitHub Integration
- ✅ Workspace Cleanup
- ✅ Configuration as Code
- ✅ Kubernetes
- ✅ LDAP
- ✅ Matrix Authorization Strategy

Then **restart Jenkins** when prompted.

---

## 📋 Labs

| # | Lab | Difficulty | Scenario | Key Error |
|---|-----|-----------|----------|-----------|
| 01 | [Pipeline Syntax](lab-01-pipeline-syntax/) | ⭐ Easy | Declarative syntax errors | `Not a valid section definition` |
| 02 | [Agent Offline](lab-02-agent-offline/) | ⭐ Easy | Agent label mismatch | `Waiting for next available executor` |
| 03 | [Credentials Binding](lab-03-credentials-binding/) | ⭐⭐ Medium | Wrong credential ID/type | `CredentialNotFoundException` |
| 04 | [Shared Library](lab-04-shared-library/) | ⭐⭐ Medium | Library not configured | `Library 'wrong-name' not found` |
| 05 | [Parallel Stages](lab-05-parallel-stages/) | ⭐⭐ Medium | Workspace conflicts | Flaky file-not-found errors |
| 06 | [Artifact Failures](lab-06-artifact-failures/) | ⭐⭐ Medium | Wrong archive pattern | `No artifacts found matching` |
| 07 | [Docker-in-Docker](lab-07-docker-in-docker/) | ⭐⭐⭐ Hard | Docker socket missing | `Cannot connect to Docker daemon` |
| 08 | [Webhook Triggers](lab-08-webhook-triggers/) | ⭐⭐ Medium | Trigger misconfigured | Webhook received, no build |
| 09 | [Workspace Disk Full](lab-09-workspace-disk-full/) | ⭐⭐ Medium | No cleanup | `No space left on device` |
| 10 | [Matrix Build](lab-10-matrix-build/) | ⭐⭐⭐ Hard | Bad axis/exclude config | `Invalid matrix configuration` |
| 11 | [CasC YAML Merge](lab-11-casc-yaml-merge/) | ⭐⭐⭐⭐ Expert | JCasC config errors | `YAML merge key failed` |
| 12 | [K8s Cloud Plugin](lab-12-kubernetes-cloud-plugin/) | ⭐⭐⭐⭐ Expert | Pod template issues | `Pod never scheduled` |
| 13 | [Pipeline Replay](lab-13-pipeline-replay-divergence/) | ⭐⭐⭐⭐ Expert | Replay vs SCM differences | Different behavior on replay |
| 14 | [LDAP Group Sync](lab-14-ldap-group-sync/) | ⭐⭐⭐⭐ Expert | RBAC not mapping | Login works, permissions denied |
| 15 | [Memory Leak](lab-15-pipeline-memory-leak/) | ⭐⭐⭐⭐⭐ Expert | CPS/Groovy memory issues | Jenkins master OOM killed |

---

## 🛠️ Useful Troubleshooting Commands

### Jenkins CLI:
```bash
# Check Jenkins logs
docker logs jenkins-lab-XX

# Access Jenkins Script Console (Manage Jenkins → Script Console)
println Jenkins.instance.computers*.name
println Jenkins.instance.pluginManager.plugins*.shortName

# Validate Jenkinsfile syntax via API
curl -X POST -F "jenkinsfile=<Jenkinsfile" \
  http://localhost:8080/pipeline-model-converter/validate
```

### From Dashboard:
- **Console Output**: Build → Console Output (see exact error)
- **Pipeline Steps**: Build → Pipeline Steps (see which step failed)
- **Blue Ocean**: Better visualization of parallel/matrix stages
- **Replay**: Build → Replay (edit and re-run without committing)
- **Restart from Stage**: Re-run from specific failed stage

---

## 💡 Tips

- **Read the console error first** — 90% of the answer is there
- **Check plugin compatibility** — many issues come from plugin version mismatches
- **Use Pipeline Syntax helper** — Jenkins UI has a snippet generator (Pipeline Syntax link in job page)
- **Declarative vs Scripted** — `def` variables need `script {}` blocks in declarative
- **Credentials scope** — credentials must be defined in the right scope/domain
- **Agent labels** — labels are case-sensitive and must match exactly

---

## 📁 File Structure (each lab)

```
lab-XX-name/
├── Jenkinsfile        # The BROKEN pipeline (paste into Jenkins)
├── README.md          # Scenario, hints, expected error
├── solution.md        # Full fix with explanation
├── deploy.sh          # Starts Jenkins in Docker
└── cleanup.sh         # Removes Jenkins container
```

---

## Prerequisites

- Docker installed and running
- Ports 8080 and 50000 available
- Browser for Jenkins UI
- ~5 minutes for initial Jenkins setup (first time only)
