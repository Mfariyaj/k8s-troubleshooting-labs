# 🎯 Spinnaker Troubleshooting Labs


## 🚀 How To Use These Labs



### Prerequisites:

- Spinnaker installed (via Halyard or Spinnaker Operator)

- `spin` CLI installed

- `hal` CLI installed (for Halyard labs)



### Steps:

1. `cd lab-01-halyard-config-broken && ./deploy.sh`

2. Try to apply the config: `hal deploy apply`

3. Read the Halyard/Spinnaker error

4. Fix the configuration

5. Re-deploy and verify on Spinnaker UI (http://localhost:9000)

6. Cleanup: `./cleanup.sh`



---


## 15 Real-World Broken Scenarios for Spinnaker Engineers

---

## What is Spinnaker?

Spinnaker is an **open-source, multi-cloud continuous delivery platform** originally built by Netflix and now maintained by the Continuous Delivery Foundation (CDF). Unlike traditional CI/CD tools that treat deployment as just another step in a pipeline, Spinnaker treats **deployment pipelines as first-class citizens** with native support for advanced deployment strategies.

### Key Features:
- **Multi-cloud deployments**: Kubernetes, AWS EC2/ECS, Google Cloud, Azure, Oracle Cloud, CloudFoundry
- **Advanced deployment strategies**: Canary, Blue-Green (Red/Black), Rolling Red/Black, Highlander, Custom
- **Automated Canary Analysis (ACA)**: Statistical comparison of canary vs baseline metrics via Kayenta
- **Pipeline orchestration**: Complex multi-stage pipelines with conditional execution, manual judgments, and rollback
- **Immutable infrastructure**: Bake (create) images, then deploy — no in-place mutations
- **GitOps-ready**: Pipeline-as-code via Pipeline Templates (MPT v2) and Managed Delivery

### What Makes Spinnaker Different from Jenkins/GitHub Actions/ArgoCD?
| Feature | Jenkins/GHA | ArgoCD | Spinnaker |
|---------|-------------|--------|-----------|
| CI (build/test) | ✅ Primary | ❌ | ❌ (uses Igor to integrate) |
| CD (deploy) | ⚠️ Basic | ✅ GitOps | ✅ Advanced strategies |
| Multi-cloud | ⚠️ Plugins | ❌ K8s only | ✅ Native |
| Canary analysis | ❌ | ❌ | ✅ Kayenta |
| Deployment strategies | ❌ Manual | ⚠️ Basic | ✅ First-class |
| Pipeline orchestration | ✅ | ❌ | ✅ |

---

## Architecture Overview

Spinnaker is composed of **11+ microservices**, each responsible for a specific domain. Understanding this architecture is crucial for troubleshooting.

```
┌─────────────────────────────────────────────────────────────────┐
│                         User / CI System                         │
└───────────────┬─────────────────────────────────┬───────────────┘
                │ UI (port 9000)                   │ API (port 8084)
         ┌──────▼──────┐                    ┌──────▼──────┐
         │    Deck     │                    │    Gate     │
         │  (React UI) │                    │ (API GW)   │
         └─────────────┘                    └──────┬──────┘
                                                   │
              ┌────────────────────────────────────┼────────────────┐
              │                                    │                │
       ┌──────▼──────┐  ┌──────────────┐  ┌──────▼──────┐  ┌─────▼─────┐
       │    Orca     │  │   Clouddriver │  │   Front50   │  │   Fiat    │
       │(Orchestrator)│  │(Cloud Provdr) │  │ (Metadata)  │  │  (AuthZ)  │
       └──────┬──────┘  └──────┬───────┘  └──────┬──────┘  └───────────┘
              │                │                   │
       ┌──────▼──────┐  ┌─────▼────┐      ┌──────▼──────┐
       │    Echo     │  │  Rosco   │      │  S3/GCS/    │
       │(Events/Ntfy)│  │ (Baker)  │      │  SQL/Redis  │
       └─────────────┘  └──────────┘      └─────────────┘
              │
       ┌──────▼──────┐  ┌──────────┐
       │    Igor     │  │  Kayenta │
       │(CI Triggers)│  │ (Canary) │
       └─────────────┘  └──────────┘
```

### Microservice Breakdown:

| Service | Port | Role | What Breaks |
|---------|------|------|-------------|
| **Deck** | 9000 | React SPA UI for users | CORS issues, Gate connectivity |
| **Gate** | 8084 | API Gateway — all requests go through here | Auth headers, SSL termination, session issues |
| **Orca** | 8083 | Orchestration engine — executes pipeline stages | Stage timeouts, expression errors, task failures |
| **Clouddriver** | 7002 | Cloud provider integration (K8s, AWS, GCP) | Account config, credentials, API connectivity |
| **Front50** | 8080 | Metadata storage (pipelines, apps, notifications) | Storage backend issues (S3/GCS/SQL/Redis) |
| **Rosco** | 8087 | Image baker (Packer-based AMI/image creation) | Packer templates, base image not found, timeouts |
| **Igor** | 8088 | CI system integration + Docker Registry polling | Trigger failures, registry auth, polling intervals |
| **Echo** | 8089 | Event bus + notifications (Slack/Email/Webhooks) | Notification delivery, event routing, Slack tokens |
| **Kayenta** | 8090 | Automated Canary Analysis (statistical) | Metric queries, thresholds, storage config |
| **Fiat** | 7003 | Authorization/RBAC service | Permission sync, role mapping, service accounts |
| **Halyard** | 8064 | CLI for configuring & deploying Spinnaker | Config validation, version compatibility |

---

## Key Concepts

### Applications & Pipelines
- **Application**: Top-level organizational unit (like a microservice). Contains clusters, load balancers, pipelines.
- **Pipeline**: A sequence of stages that deploy, test, or promote your application.
- **Stage**: A single action in a pipeline (Deploy, Bake, Manual Judgment, Wait, Canary, etc.)

### Infrastructure Concepts
- **Server Group**: A group of identical instances (K8s ReplicaSet, AWS ASG). The atomic deployment unit.
- **Cluster**: A collection of server groups with the same name (app-stack-detail pattern)
- **Load Balancer**: Routes traffic to server groups (K8s Service, AWS ELB/ALB)
- **Security Group**: Firewall rules (AWS Security Groups, K8s NetworkPolicies)

### Deployment Strategies
- **Red/Black (Blue-Green)**: Deploy new server group → enable → disable old
- **Canary**: Deploy small % → analyze metrics → promote or rollback
- **Rolling Red/Black**: Red/Black but with max surge/unavailable settings
- **Highlander**: Red/Black but destroys (not disables) old server group
- **Custom**: User-defined strategy using pipeline expressions and stages

### Pipeline Expressions (SpEL)
Spinnaker uses Spring Expression Language (SpEL) for dynamic values:
```
${trigger.parameters.environment}
${execution.stages.?[name == 'Bake'].get(0).outputs.artifacts}
${#stage('Deploy').status == 'SUCCEEDED'}
${#judgment('Approve Production')}
```

### Pipeline Templates (MPT v2)
Reusable pipeline definitions with variables:
```json
{
  "schema": "v2",
  "variables": [
    { "name": "environment", "type": "string" }
  ],
  "pipeline": { ... }
}
```

### Managed Delivery (Declarative Delivery)
GitOps-style declarative approach:
```yaml
name: my-app
environments:
  - name: testing
    constraints: []
    resources:
      - kind: titus/cluster@v1
        spec: ...
```

---

## Installation Methods

### 1. Halyard (Traditional)
```bash
curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
sudo bash InstallHalyard.sh
hal version list
hal config version edit --version 1.32.0
hal deploy apply
```

### 2. Spinnaker Operator (Kubernetes-Native)
```bash
kubectl apply -f https://github.com/armory/spinnaker-operator/releases/latest/download/manifests.tgz
kubectl apply -f spinnakerservice.yaml
```

### 3. Armory Enterprise (Commercial)
Armory provides an enterprise distribution with additional features like policy engine, secrets management, and support.

---

## Common CLI Commands

### Halyard (hal)
```bash
hal version list                                    # List available Spinnaker versions
hal config version edit --version 1.32.0           # Set Spinnaker version
hal config provider kubernetes enable               # Enable K8s provider
hal config provider kubernetes account add my-k8s \
  --context my-context \
  --kubeconfig-file /path/to/kubeconfig            # Add K8s account
hal config storage s3 edit --bucket my-bucket      # Configure S3 storage
hal config storage edit --type s3                  # Set storage type
hal config deploy edit --type distributed          # Distributed deployment
hal deploy apply                                   # Apply all config changes
hal deploy diff                                    # Show pending changes
```

### Spin CLI
```bash
spin application list                               # List all applications
spin pipeline list --application myapp             # List pipelines for an app
spin pipeline get --name deploy --application myapp # Get pipeline JSON
spin pipeline save --file pipeline.json            # Save/update pipeline
spin pipeline execute --name deploy --application myapp  # Trigger pipeline
spin pipeline-template list                        # List pipeline templates
```

### Kubectl (for Spinnaker pods)
```bash
kubectl get pods -n spinnaker                      # Check pod status
kubectl logs -n spinnaker spin-clouddriver-xxx     # View Clouddriver logs
kubectl logs -n spinnaker spin-orca-xxx            # View Orca logs
kubectl describe pod -n spinnaker spin-gate-xxx    # Describe Gate pod
kubectl exec -it -n spinnaker spin-front50-xxx -- curl localhost:8080/health
```

---

## Official Documentation

- 📘 Main Docs: https://spinnaker.io/docs/
- 🔧 Setup Guide: https://spinnaker.io/docs/setup/
- 🔀 Pipeline Guide: https://spinnaker.io/docs/guides/user/pipeline/
- 📋 Stage Reference: https://spinnaker.io/docs/reference/pipeline/stages/
- 💬 Expression Reference: https://spinnaker.io/docs/reference/pipeline/expressions/
- 🏗️ Architecture: https://spinnaker.io/docs/reference/architecture/
- 🔐 Security: https://spinnaker.io/docs/setup/security/

---

## 🗂️ Lab Index

| # | Lab | Difficulty | What's Broken |
|---|-----|-----------|---------------|
| 01 | [Halyard Config Broken](lab-01-halyard-config-broken/) | 🟢 Beginner | S3 storage backend misconfigured |
| 02 | [Clouddriver K8s Account](lab-02-clouddriver-k8s-account/) | 🟢 Beginner | Kubernetes account can't connect |
| 03 | [Pipeline Expression Error](lab-03-pipeline-expression-error/) | 🟡 Intermediate | SpEL expression evaluation failure |
| 04 | [Deploy Manifest Stage](lab-04-deploy-manifest-stage/) | 🟡 Intermediate | Manifest deployment fails with artifact errors |
| 05 | [Canary Analysis Failure](lab-05-canary-analysis-failure/) | 🔴 Advanced | Kayenta ACA always reports failure |
| 06 | [Blue-Green Rollback](lab-06-blue-green-rollback/) | 🟡 Intermediate | Red/Black rollback fails |
| 07 | [Trigger Not Firing](lab-07-trigger-not-firing/) | 🟡 Intermediate | Docker/Webhook triggers not working |
| 08 | [Pipeline Template Broken](lab-08-pipeline-template-broken/) | 🔴 Advanced | MPT v2 instantiation fails |
| 09 | [RBAC Fiat Denied](lab-09-rbac-fiat-denied/) | 🔴 Advanced | Authorization blocks access incorrectly |
| 10 | [Artifact Resolution Failed](lab-10-artifact-resolution-failed/) | 🟡 Intermediate | Artifact binding/matching fails |
| 11 | [Notification Not Sending](lab-11-notification-not-sending/) | 🟡 Intermediate | Echo/Slack notifications broken |
| 12 | [Bake Stage Failure](lab-12-bake-stage-failure/) | 🔴 Advanced | Rosco/Packer bake fails |
| 13 | [Spinnaker Operator Crash](lab-13-spinnaker-operator-crash/) | 🔴 Advanced | Operator-deployed services crashing |
| 14 | [Managed Pipeline Delivery](lab-14-managed-pipeline-delivery/) | 🟣 Expert | Declarative delivery not converging |
| 15 | [Multi-Cloud Deployment](lab-15-multi-cloud-deployment/) | 🟣 Expert | K8s + AWS cross-cloud pipeline fails |

---

## 🚀 Quick Start

### Deploy a single lab:
```bash
cd spinnaker-labs/lab-01-halyard-config-broken
./deploy.sh
```

### Deploy all labs:
```bash
cd spinnaker-labs
./deploy-all.sh
```

### Clean up a single lab:
```bash
cd spinnaker-labs/lab-01-halyard-config-broken
./cleanup.sh
```

### Clean up all labs:
```bash
cd spinnaker-labs
./cleanup-all.sh
```

---

## 📋 Prerequisites

| Tool | Required | Install |
|------|----------|---------|
| `hal` (Halyard) | Labs 1, 2, 5-12 | `curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh` |
| `spin` CLI | Labs 3, 4, 6-11 | `curl -LO https://storage.googleapis.com/spinnaker-artifacts/spin/latest/linux/amd64/spin` |
| `kubectl` | All labs | https://kubernetes.io/docs/tasks/tools/ |
| K8s cluster | All labs | minikube/kind/EKS/GKE |
| `jq` | Helpful for all | `apt install jq` |
| AWS CLI | Labs 1, 12, 15 | `pip install awscli` |

---

## ⚔️ Rules of Engagement

1. Deploy the lab → investigate using only CLI tools → identify root cause → fix it
2. Don't look at solution.md until you've spent at least 10 minutes troubleshooting
3. Use `hal`, `spin`, `kubectl logs`, and `kubectl describe` as your primary tools
4. Time yourself — experienced Spinnaker engineers solve most in under 15 minutes
5. Document what you find — these are real production scenarios

---

## 💡 Troubleshooting Tips

1. **Always check pod logs first**: `kubectl logs -n spinnaker <pod>`
2. **Use the health endpoints**: Each service exposes `/health` on its port
3. **Check Orca for pipeline failures**: Orca logs show stage execution details
4. **Clouddriver for deployment issues**: Account config and cloud API errors
5. **Front50 for "not found" errors**: Storage backend connectivity
6. **Echo for notification issues**: Event routing and delivery failures
7. **Fiat for permission denied**: Role sync and application permissions
8. **Halyard for config issues**: `hal config` commands to inspect current state

---

## 📜 License

MIT License — break things freely, fix them wisely.
