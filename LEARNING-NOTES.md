# 📚 DevOps Tools Learning Notes

## Complete Reference for All 28 Tools in This Repository

---

# 🔐 HashiCorp Vault

## What is it?
Vault is a **secrets management** tool. It securely stores and controls access to API keys, passwords, certificates, and encryption keys.

## Why DevOps needs it:
- Never hardcode secrets in code/configs
- Auto-rotate database passwords
- Generate short-lived credentials (dynamic secrets)
- Encrypt application data without managing keys yourself

## Architecture:
```
┌─────────────────────────────────────────┐
│              Vault Server                │
│  ┌──────────┐  ┌────────────────────┐   │
│  │ Auth     │  │ Secret Engines     │   │
│  │ Methods  │  │ - KV (key-value)   │   │
│  │ - Token  │  │ - Database         │   │
│  │ - AppRole│  │ - PKI (certs)      │   │
│  │ - K8s    │  │ - Transit (encrypt)│   │
│  │ - LDAP   │  │ - AWS/GCP/Azure    │   │
│  └──────────┘  └────────────────────┘   │
│  ┌──────────┐  ┌────────────────────┐   │
│  │ Policies │  │ Audit Devices      │   │
│  │ (ACL)    │  │ - File / Syslog    │   │
│  └──────────┘  └────────────────────┘   │
└─────────────────────────────────────────┘
```

## Key Commands:
```bash
vault status                    # Check if sealed/unsealed
vault login <token>             # Authenticate
vault kv put secret/myapp key=value  # Store secret
vault kv get secret/myapp       # Read secret
vault secrets enable -path=kv kv-v2  # Enable engine
vault policy write mypolicy policy.hcl  # Create policy
vault auth enable approle       # Enable auth method
```

## Reference: https://developer.hashicorp.com/vault/docs

---

# ☁️ AWS Troubleshooting

## Common Issues DevOps Engineers Face:

### IAM (Identity & Access Management):
- **AccessDenied** = Missing permission in policy OR wrong resource ARN
- **AssumeRole failed** = Trust policy doesn't allow the caller
- Fix: Check `aws sts get-caller-identity`, then review policies

### VPC & Networking:
- **Can't reach internet** = Missing NAT Gateway in private subnet route table
- **Connection timeout** = Security Group blocking port, or NACL denying
- **DNS not resolving** = enableDnsSupport/enableDnsHostnames not enabled

### EKS:
- **Nodes NotReady** = aws-auth ConfigMap missing node IAM role
- **Pods can't pull images** = Node IAM role missing ECR permissions
- **Service type LoadBalancer stuck** = Missing aws-load-balancer-controller

### Key Commands:
```bash
aws sts get-caller-identity     # Who am I?
aws iam simulate-principal-policy  # Test permissions
aws ec2 describe-security-groups   # Check SG rules
aws eks update-kubeconfig          # Get K8s access
aws logs get-log-events            # Read CloudWatch logs
```

## Reference: https://docs.aws.amazon.com/

---

# 📦 Kustomize

## What is it?
Kustomize is a **Kubernetes manifest customization** tool. It lets you have a base config and create overlays (dev/staging/prod) without templating.

## How it differs from Helm:
- **Helm** = templating ({{ .Values.x }}) → generates YAML
- **Kustomize** = patching (keep original YAML, apply patches on top)
- Kustomize is built into `kubectl apply -k`

## Key Concepts:
```
base/                    ← Original YAML (shared)
├── deployment.yaml
├── service.yaml
└── kustomization.yaml

overlays/
├── dev/                 ← Dev-specific patches
│   ├── kustomization.yaml (references ../base + patches)
│   └── replicas-patch.yaml
└── prod/                ← Prod-specific patches
    ├── kustomization.yaml
    └── resources-patch.yaml
```

## Key Commands:
```bash
kustomize build overlays/prod    # Render final YAML
kubectl apply -k overlays/prod   # Apply directly
kustomize build . | kubectl diff -f -  # Preview changes
```

## Common Features:
- `namePrefix` / `nameSuffix` — add prefix to all resource names
- `commonLabels` — add labels to everything
- `patchesStrategicMerge` — patch specific fields
- `configMapGenerator` / `secretGenerator` — auto-create from files

## Reference: https://kustomize.io/

---

# 🔭 OpenTelemetry (OTel)

## What is it?
OpenTelemetry is a **unified observability framework** for traces, metrics, and logs. It's replacing vendor-specific tools (Datadog agent, Jaeger client, Prometheus client).

## Why it matters:
- **One SDK** for all telemetry (instead of 3 separate ones)
- **Vendor-neutral** — switch from Datadog to Grafana Cloud without code changes
- **Industry standard** — CNCF graduated project

## Architecture:
```
┌──────────┐     ┌────────────────────┐     ┌──────────────┐
│ Your App │────>│  OTel Collector    │────>│ Backend      │
│ (SDK)    │     │  - Receivers       │     │ - Jaeger     │
│          │     │  - Processors      │     │ - Prometheus │
│ Traces   │     │  - Exporters       │     │ - Datadog    │
│ Metrics  │     │                    │     │ - Grafana    │
│ Logs     │     └────────────────────┘     └──────────────┘
└──────────┘
```

## Three Signals:
1. **Traces** — Follow a request across microservices (distributed tracing)
2. **Metrics** — Counters, gauges, histograms (like Prometheus)
3. **Logs** — Structured log events with trace correlation

## Key Config (Collector):
```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
    timeout: 5s

exporters:
  prometheus:
    endpoint: 0.0.0.0:8889
  jaeger:
    endpoint: jaeger:14250

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [jaeger]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [prometheus]
```

## Reference: https://opentelemetry.io/docs/

---

# 🛡️ DevSecOps

## What is it?
**Security integrated into the DevOps pipeline** — shift security LEFT (earlier in the process, not just at the end).

## Key Tools:

| Tool | What It Does | When It Runs |
|------|-------------|-------------|
| **Trivy** | Scan container images for CVEs | CI pipeline (build stage) |
| **SonarQube** | Static code analysis (bugs, vulnerabilities) | CI pipeline (test stage) |
| **OPA/Gatekeeper** | Policy enforcement on K8s (block risky configs) | Admission webhook |
| **Falco** | Runtime security (detect suspicious activity) | Running in cluster |
| **Snyk** | Dependency vulnerability scanning | CI + IDE |
| **Cosign** | Container image signing (supply chain) | CI pipeline (push stage) |

## DevSecOps Pipeline:
```
Code → SAST (SonarQube) → Build → Image Scan (Trivy) → Sign (Cosign) → 
Deploy → Admission (OPA) → Runtime (Falco) → Monitor
```

## Key Commands:
```bash
trivy image nginx:latest              # Scan image
trivy fs --security-checks vuln .     # Scan filesystem
sonar-scanner -Dsonar.projectKey=myapp  # Code scan
cosign sign --key cosign.key myimage   # Sign image
kubectl get constrainttemplates        # OPA policies
falco --list                           # Falco rules
```

## Reference: https://www.devsecops.org/

---

# 💥 Chaos Engineering

## What is it?
**Intentionally breaking things in production** to find weaknesses before they cause outages. Netflix pioneered this with "Chaos Monkey."

## Principles:
1. Define "steady state" (what normal looks like)
2. Hypothesize: "system will handle X failure gracefully"
3. Introduce failure (kill pods, add latency, fill disk)
4. Observe: Did alerts fire? Did it recover? How long?
5. Fix weaknesses found

## Tools:
| Tool | What It Does |
|------|-------------|
| **Litmus Chaos** | K8s-native chaos experiments (ChaosEngine CRD) |
| **Chaos Mesh** | Comprehensive K8s chaos (network, time, stress) |
| **Gremlin** | Enterprise chaos platform (SaaS) |
| **Toxiproxy** | Simulate network failures between services |

## Example Experiments:
```yaml
# Litmus: Kill random pods
apiVersion: litmuschaos.io/v1alpha1
kind: ChaosEngine
spec:
  appinfo:
    appns: production
    applabel: app=payment-service
  experiments:
    - name: pod-delete
      spec:
        components:
          env:
            - name: TOTAL_CHAOS_DURATION
              value: '30'
            - name: CHAOS_INTERVAL
              value: '10'
```

## Reference: https://litmuschaos.io/ | https://principlesofchaos.org/

---

# 🔄 Flux CD

## What is it?
Flux is a **GitOps tool** for Kubernetes (alternative to ArgoCD). It keeps your cluster in sync with a Git repository automatically.

## Flux vs ArgoCD:
| Feature | Flux | ArgoCD |
|---------|------|--------|
| UI | Minimal (Weave GitOps) | Built-in rich UI |
| Architecture | Controllers per CRD | Single monolithic server |
| Multi-tenancy | Native (per namespace) | Via AppProjects |
| Image automation | Built-in | Separate Image Updater |
| Helm support | HelmRelease CRD | Application CRD |

## Key CRDs:
```yaml
# GitRepository — where to pull from
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
spec:
  url: https://github.com/myorg/myapp
  interval: 1m

# Kustomization — what to deploy
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
spec:
  sourceRef:
    kind: GitRepository
    name: myapp
  path: ./k8s/overlays/production
  interval: 5m
  prune: true

# HelmRelease — deploy Helm charts
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
spec:
  chart:
    spec:
      chart: mychart
      sourceRef:
        kind: HelmRepository
        name: myrepo
```

## Key Commands:
```bash
flux install                    # Install Flux in cluster
flux create source git myapp    # Add git source
flux get kustomizations         # Check sync status
flux reconcile kustomization myapp  # Force sync
flux logs                       # See controller logs
```

## Reference: https://fluxcd.io/docs/

---

# 🌐 Crossplane

## What is it?
Crossplane turns your **Kubernetes cluster into a universal cloud control plane**. Create AWS/GCP/Azure resources using Kubernetes YAML.

## Why use it:
- Manage cloud resources (RDS, S3, VPC) with kubectl
- Compose multiple resources into reusable "Compositions"
- Platform teams create APIs, dev teams consume them
- Alternative to Terraform — uses K8s reconciliation loop

## Key Concepts:
```
XRD (CompositeResourceDefinition) → Defines the API
Composition → Maps API fields to actual cloud resources
Claim → What developers use (simplified interface)
Provider → Connects to AWS/GCP/Azure (runs as a pod)
```

## Example:
```yaml
# Developer creates this (simple):
apiVersion: database.example.com/v1alpha1
kind: PostgreSQLInstance
metadata:
  name: my-db
spec:
  storageGB: 20
  version: "14"

# Crossplane creates this (complex, behind the scenes):
# - RDS Instance
# - Security Group
# - Subnet Group
# - IAM Role
# - Secret with credentials
```

## Reference: https://docs.crossplane.io/

---

# 🔄 Argo Workflows

## What is it?
Argo Workflows is a **Kubernetes-native workflow engine** for running complex DAG-based CI/CD pipelines, data processing, and ML workflows.

## How it differs from Jenkins/GitHub Actions:
- Runs entirely on Kubernetes (pods as steps)
- DAG support (parallel + dependent steps)
- Artifacts passed via S3/MinIO between steps
- Template library (reusable across workflows)

## Example:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
spec:
  entrypoint: my-pipeline
  templates:
    - name: my-pipeline
      dag:
        tasks:
          - name: build
            template: build-step
          - name: test
            template: test-step
            dependencies: [build]
          - name: deploy
            template: deploy-step
            dependencies: [test]
```

## Key Commands:
```bash
argo submit workflow.yaml        # Run workflow
argo list                        # List workflows
argo get my-workflow             # Status
argo logs my-workflow            # Logs
argo cron list                   # Cron workflows
```

## Reference: https://argoproj.github.io/argo-workflows/

---

# 🐝 Cilium

## What is it?
Cilium is a **Kubernetes CNI plugin** powered by **eBPF**. It provides networking, security, and observability without iptables.

## Why it's trending:
- **Faster** than iptables-based CNIs (Calico, Flannel)
- **Service mesh** without sidecars (kernel-level)
- **Hubble** — observability for network flows
- **eBPF** — programmable kernel (no overhead)

## Features:
| Feature | What It Does |
|---------|-------------|
| CNI | Pod networking (replaces kube-proxy) |
| Network Policy | L3/L4/L7 policies (HTTP-aware!) |
| Service Mesh | mTLS, traffic management (no sidecar) |
| Hubble | Network flow visualization |
| Cluster Mesh | Multi-cluster networking |
| Bandwidth Manager | Rate limiting per pod |

## Key Commands:
```bash
cilium status                    # Check Cilium health
cilium connectivity test         # Run connectivity tests
hubble observe                   # Watch network flows
cilium policy get                # List policies
cilium endpoint list             # List endpoints
```

## Reference: https://docs.cilium.io/

---

# 🦭 Podman

## What is it?
Podman is a **Docker alternative** that runs containers **without a daemon** (daemonless) and supports **rootless** containers.

## Why use Podman over Docker:
- **No daemon** — no single point of failure
- **Rootless** — containers run as regular user (more secure)
- **Docker-compatible** — same CLI commands
- **Systemd integration** — run containers as services
- **Pod support** — group containers (like K8s pods)

## Key Commands:
```bash
podman run -d nginx              # Same as docker!
podman pod create --name mypod   # Create a pod
podman generate systemd mycontainer  # Create systemd unit
podman play kube pod.yaml        # Run K8s YAML locally
buildah build -t myimage .       # Build images (OCI-native)
```

## Reference: https://podman.io/docs/

---

# 📊 Datadog / ELK Stack

## ELK = Elasticsearch + Logstash + Kibana

```
App Logs → Filebeat → Logstash (parse/transform) → Elasticsearch (store/index) → Kibana (visualize)
```

- **Elasticsearch** — Search engine for logs (stores + indexes)
- **Logstash** — Pipeline: receive, parse, transform, output
- **Kibana** — Dashboard for searching and visualizing logs
- **Filebeat** — Lightweight shipper (tails log files)

## Datadog — SaaS Observability Platform:
- Agent installed on hosts/pods
- Metrics, logs, traces, RUM all in one
- 750+ integrations
- AI-powered alerting

## Key Commands:
```bash
# ELK
curl -X GET "localhost:9200/_cluster/health"   # ES health
curl -X GET "localhost:9200/_cat/indices"       # List indices

# Datadog
datadog-agent status                           # Agent health
datadog-agent check <integration>              # Test check
```

## Reference: https://www.elastic.co/guide/ | https://docs.datadoghq.com/

---

# 🏢 Terraform Cloud / Atlantis

## Terraform Cloud (TFC):
- **Remote state** — store state securely (not in S3)
- **Remote runs** — plan/apply in TFC, not locally
- **Sentinel** — policy-as-code (block expensive resources)
- **Private registry** — share modules across teams
- **VCS integration** — auto-plan on PR

## Atlantis:
- Self-hosted alternative to TFC
- GitHub/GitLab PR automation
- `atlantis plan` / `atlantis apply` as PR comments
- Runs terraform in your own infrastructure

## Reference: https://developer.hashicorp.com/terraform/cloud-docs | https://www.runatlantis.io/

---

# 🎪 Backstage (Spotify)

## What is it?
Backstage is an **Internal Developer Portal** (IDP). It's a single UI where developers find documentation, services, APIs, and create new projects.

## Key Features:
- **Software Catalog** — find all services, owners, APIs
- **TechDocs** — docs-as-code (Markdown → website)
- **Software Templates** — scaffold new microservices
- **Plugins** — extend with K8s, CI/CD, cost, etc.
- **Search** — find anything across the org

## Reference: https://backstage.io/docs/

---

# 📖 Quick Reference — All Tools

| Tool | One-line Description | Category |
|------|---------------------|----------|
| Vault | Secrets management | Security |
| AWS | Cloud infrastructure | Cloud |
| Kustomize | K8s manifest patching | K8s |
| OpenTelemetry | Traces + metrics + logs | Observability |
| DevSecOps | Security in pipeline | Security |
| Chaos Engineering | Break things to improve | Reliability |
| Flux CD | GitOps for K8s | GitOps |
| Crossplane | Cloud resources via K8s | IaC |
| Argo Workflows | K8s-native pipelines | CI/CD |
| Cilium | eBPF networking | Networking |
| Podman | Daemonless containers | Containers |
| Datadog/ELK | Log aggregation & APM | Observability |
| Terraform Cloud | Remote Terraform | IaC |
| Backstage | Developer portal | Platform |
