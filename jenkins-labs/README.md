# 🔧 Jenkins Troubleshooting Labs

## 10 Real-World Broken Jenkins Scenarios

---

## Overview

Each lab contains an intentionally broken Jenkins pipeline or configuration. Deploy Jenkins in Docker, load the Jenkinsfile, and diagnose the failure using only the Jenkins console output and CLI tools.

---

## Labs

| # | Lab | Difficulty | Key Concept |
|---|-----|-----------|-------------|
| 01 | [Pipeline Syntax Errors](lab-01-pipeline-syntax/) | ⭐ Easy | Declarative pipeline syntax rules |
| 02 | [Agent Offline](lab-02-agent-offline/) | ⭐ Easy | Agent labels and node availability |
| 03 | [Credentials Binding](lab-03-credentials-binding/) | ⭐⭐ Medium | Credential IDs and type mismatches |
| 04 | [Shared Library](lab-04-shared-library/) | ⭐⭐ Medium | Global shared library configuration |
| 05 | [Parallel Stages](lab-05-parallel-stages/) | ⭐⭐ Medium | Workspace conflicts in parallel execution |
| 06 | [Artifact Failures](lab-06-artifact-failures/) | ⭐⭐ Medium | archiveArtifacts and stash/unstash |
| 07 | [Docker-in-Docker](lab-07-docker-in-docker/) | ⭐⭐⭐ Hard | Docker socket and DinD patterns |
| 08 | [Webhook Triggers](lab-08-webhook-triggers/) | ⭐⭐ Medium | SCM triggers and webhook configuration |
| 09 | [Workspace Disk Full](lab-09-workspace-disk-full/) | ⭐⭐ Medium | Workspace cleanup and disk management |
| 10 | [Matrix Build](lab-10-matrix-build/) | ⭐⭐⭐ Hard | Matrix axes and exclude directives |

---

## Quick Start

```bash
cd lab-01-pipeline-syntax
./deploy.sh        # Starts Jenkins in Docker
# Open http://localhost:8080, create a pipeline job with the Jenkinsfile
# Observe the error, diagnose, and fix!
./cleanup.sh       # Stops and removes the container
```

---

## Prerequisites

- Docker and Docker Compose installed
- Ports 8080 and 50000 available
- Basic familiarity with Jenkins pipeline syntax

---

## Rules

1. Deploy the lab → run the pipeline → read the console error
2. Diagnose using only the Jenkins UI/CLI and your knowledge
3. Fix the Jenkinsfile or configuration
4. Target: solve each lab in under 10 minutes
