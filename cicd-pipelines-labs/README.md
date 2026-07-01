# 🔧 CI/CD Pipelines Troubleshooting Labs

## 10 Real-World Broken CI/CD Pipeline Scenarios

---

## Overview

These labs simulate **intentionally broken** CI/CD pipelines across GitHub Actions and GitLab CI. Each lab presents a real-world failure scenario that you must diagnose and fix using pipeline logs, linting tools, and your troubleshooting skills.

---

## 🗂️ Lab Index

| # | Lab | Difficulty | Focus Area |
|---|-----|-----------|------------|
| 01 | [GitHub Actions Syntax Errors](lab-01-github-actions-syntax/) | 🟢 Easy | YAML syntax, workflow structure |
| 02 | [Secrets Exposed in Logs](lab-02-secrets-exposed/) | 🟡 Medium | Secret management, masking |
| 03 | [Matrix Strategy Overload](lab-03-matrix-strategy/) | 🟡 Medium | Matrix combinations, limits |
| 04 | [Artifact Passing Between Jobs](lab-04-artifact-passing/) | 🟡 Medium | Artifacts, job dependencies |
| 05 | [Environment Protection Rules](lab-05-environment-protection/) | 🟠 Hard | Environments, deployment gates |
| 06 | [Container Registry Push Failures](lab-06-container-registry-push/) | 🟠 Hard | Docker, GHCR, authentication |
| 07 | [GitLab CI Stages & Dependencies](lab-07-gitlab-ci-stages/) | 🟡 Medium | GitLab CI, stages, needs |
| 08 | [CI Cache Misses](lab-08-ci-cache-miss/) | 🟡 Medium | Caching, performance |
| 09 | [Conditional Execution Logic](lab-09-conditional-execution/) | 🟠 Hard | Path filters, conditions, rules |
| 10 | [Deployment Gates & Rollback](lab-10-deployment-gates/) | 🔴 Expert | Progressive delivery, concurrency |

---

## 🚀 Quick Start

### Deploy a single lab:
```bash
cd lab-01-github-actions-syntax
./deploy.sh
```

### Deploy all labs:
```bash
./deploy.sh
```

### Clean up all labs:
```bash
./cleanup.sh
```

---

## 📋 Prerequisites

| Tool | Purpose | Install |
|------|---------|---------|
| `git` | Local repo simulation | Pre-installed on most systems |
| `actionlint` | GitHub Actions linting | `go install github.com/rhysd/actionlint/cmd/actionlint@latest` |
| `yamllint` | YAML validation | `pip install yamllint` |
| `docker` | Container labs | [docs.docker.com](https://docs.docker.com/get-docker/) |

---

## ⚔️ Rules of Engagement

1. Deploy the lab → read the error output → diagnose the root cause → fix the pipeline
2. Use `actionlint`, `yamllint`, and manual inspection as your primary tools
3. Each lab has 3 hints in the README — try solving without them first
4. Time yourself: aim for under 10 minutes per lab
5. Document what broke and how you fixed it

---

## 📊 Progress Tracker

| Lab | Status | Time | Notes |
|-----|--------|------|-------|
| 01 - GitHub Actions Syntax | ☐ | | |
| 02 - Secrets Exposed | ☐ | | |
| 03 - Matrix Strategy | ☐ | | |
| 04 - Artifact Passing | ☐ | | |
| 05 - Environment Protection | ☐ | | |
| 06 - Container Registry Push | ☐ | | |
| 07 - GitLab CI Stages | ☐ | | |
| 08 - CI Cache Miss | ☐ | | |
| 09 - Conditional Execution | ☐ | | |
| 10 - Deployment Gates | ☐ | | |

---

## 💡 Tips

- **Read error messages carefully**: GitHub Actions and GitLab CI give detailed error output
- **Use linters**: `actionlint` catches most GitHub Actions issues offline
- **Check documentation**: Workflow syntax has strict requirements
- **Think about security**: Secrets in logs is a real production incident
- **Understand job dependencies**: Most multi-job failures are dependency-related

---

Good luck, and happy troubleshooting! 🚀
