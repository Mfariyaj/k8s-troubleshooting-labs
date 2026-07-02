# 🎯 Helm Chart Troubleshooting Labs


## 🚀 How To Use These Labs



### Prerequisites:

- `helm` 3.x installed

- For install labs: Kubernetes cluster with kubectl



### Steps:

1. `cd lab-01-values-override && ./deploy.sh`

2. Read the `helm template` error output

3. Fix Chart.yaml, values.yaml, or templates/

4. Re-run: `helm template myrelease ./mychart`

5. Cleanup: `./cleanup.sh`



---


## 10 Real-World Broken Helm Charts for DevOps Engineers

---

## Overview

These labs present intentionally broken Helm chart configurations that simulate real-world failures you'll encounter when working with Helm in production. Each lab contains a broken chart that you must diagnose and fix using only Helm CLI commands and your troubleshooting skills.

---

## 🗂️ Lab Index

| # | Lab | Difficulty | Key Concept |
|---|-----|-----------|-------------|
| 01 | [Values Override Precedence](lab-01-values-override/) | ⭐ Easy | `--set` overrides `-f` values files |
| 02 | [Template Function Errors](lab-02-template-function-errors/) | ⭐⭐ Medium | `indent` vs `nindent`, `$` scope in `range` |
| 03 | [Dependency Download Failure](lab-03-dependency-download/) | ⭐⭐ Medium | Repository URL typo, non-existent version |
| 04 | [Hook Weight Ordering](lab-04-hook-weight-ordering/) | ⭐⭐ Medium | Pre-install hook execution order |
| 05 | [Resource Name Length](lab-05-resource-name-length/) | ⭐⭐ Medium | 63-character DNS label limit |
| 06 | [Conditional Empty Documents](lab-06-conditional-empty-docs/) | ⭐⭐ Medium | Empty YAML `---` from conditionals |
| 07 | [Immutable Field Upgrade](lab-07-immutable-field-upgrade/) | ⭐⭐⭐ Hard | Version labels in selector.matchLabels |
| 08 | [Schema Validation](lab-08-schema-validation/) | ⭐⭐ Medium | Overly restrictive values.schema.json |
| 09 | [Library Chart](lab-09-library-chart/) | ⭐⭐⭐ Hard | Wrong template name reference |
| 10 | [OCI Registry Push](lab-10-oci-registry/) | ⭐⭐⭐ Hard | Wrong OCI URL, missing registry login |

---

## 🚀 Quick Start

### Deploy a single lab:
```bash
cd lab-01-values-override
./deploy.sh
```

### Deploy all labs (show all errors):
```bash
./deploy-all.sh
```

### Clean up all labs:
```bash
./cleanup-all.sh
```

---

## 📋 Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| `helm` | >= 3.10 | [helm.sh/docs/intro/install](https://helm.sh/docs/intro/install/) |
| `kubectl` | >= 1.25 | [kubernetes.io/docs/tasks/tools](https://kubernetes.io/docs/tasks/tools/) |
| K8s cluster (optional) | Any | Labs 04, 07 work best on a live cluster |
| `docker` (optional) | Any | Lab 10 can use a local registry |

Most labs use `helm template --debug` and don't require a live Kubernetes cluster.

---

## 📁 Directory Structure

```
helm-labs/
├── README.md                           # This file
├── deploy-all.sh                       # Run all labs
├── cleanup-all.sh                      # Clean up all labs
├── lab-01-values-override/             # Values precedence
│   ├── mychart/
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/deployment.yaml
│   ├── custom-values.yaml
│   ├── README.md
│   ├── deploy.sh
│   └── cleanup.sh
├── lab-02-template-function-errors/    # indent vs nindent, $ scope
├── lab-03-dependency-download/         # Broken repo URL & version
├── lab-04-hook-weight-ordering/        # Hook execution order
├── lab-05-resource-name-length/        # DNS label limit
├── lab-06-conditional-empty-docs/      # Empty YAML documents
├── lab-07-immutable-field-upgrade/     # Immutable selector labels
├── lab-08-schema-validation/           # Schema rejects valid values
├── lab-09-library-chart/               # Wrong template name
└── lab-10-oci-registry/                # OCI push failures
```

---

## 📊 Progress Tracker

| # | Lab | Status |
|---|-----|--------|
| 01 | Values Override Precedence | ☐ |
| 02 | Template Function Errors | ☐ |
| 03 | Dependency Download Failure | ☐ |
| 04 | Hook Weight Ordering | ☐ |
| 05 | Resource Name Length | ☐ |
| 06 | Conditional Empty Documents | ☐ |
| 07 | Immutable Field Upgrade | ☐ |
| 08 | Schema Validation | ☐ |
| 09 | Library Chart | ☐ |
| 10 | OCI Registry Push | ☐ |

---

## ⚔️ Rules of Engagement

1. Run `./deploy.sh` in the lab directory — observe the error
2. Diagnose using ONLY Helm CLI commands (`helm template`, `helm lint`, `helm show`)
3. Identify the root cause before looking at the README hints
4. Fix the broken configuration
5. Verify your fix with `helm template --debug` or `helm install --dry-run`
6. Time yourself — most labs should take 5-15 minutes

---

## 💡 Key Helm Debugging Commands

```bash
# Render templates locally (no cluster needed)
helm template <release> <chart> --debug

# Lint a chart for common issues
helm lint <chart>

# Dry-run install (needs cluster)
helm install <release> <chart> --dry-run --debug

# Show computed values
helm get values <release>

# Show all rendered manifests of a release
helm get manifest <release>

# Check dependencies
helm dependency list <chart>
helm dependency update <chart>

# Validate against JSON schema
helm template <release> <chart> --debug 2>&1 | head -20
```

---

## 🤝 Contributing

Want to add more broken Helm scenarios? PRs welcome! Each lab should include:
- A broken `mychart/` with intentional issues
- A `README.md` with error output, hints, and solution
- `deploy.sh` and `cleanup.sh` scripts

---

Good luck, and happy Helming! ⎈
