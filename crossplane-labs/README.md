# 🌐 Crossplane Troubleshooting Labs

## 10 Real-World Broken Cloud Infrastructure Scenarios

---

## 📚 What is Crossplane?

Crossplane turns your **Kubernetes cluster into a cloud control plane**. You create AWS/GCP/Azure resources using kubectl and YAML — no Terraform needed.

### The Big Idea:
```
Developer writes:                Platform team defined:
┌────────────────────┐          ┌─────────────────────────┐
│ apiVersion: db/v1  │          │ Composition:            │
│ kind: PostgreSQL   │  ──────> │  - RDS Instance         │
│ spec:              │  maps to │  - Security Group       │
│   size: small      │          │  - Subnet Group         │
│   version: "14"    │          │  - IAM Role             │
└────────────────────┘          │  - Secret (creds)       │
Simple claim                    └─────────────────────────┘
(dev-friendly)                  Complex cloud resources
                                (platform-managed)
```

### Crossplane vs Terraform:
| | Crossplane | Terraform |
|---|-----------|-----------|
| Language | YAML (K8s native) | HCL |
| State | Kubernetes etcd | .tfstate file |
| Reconciliation | Continuous (controller loop) | On-demand (plan/apply) |
| Drift detection | Automatic | Manual (plan) |
| Multi-tenancy | K8s RBAC/namespaces | Workspaces |

---

## 📋 Labs

| # | Lab | Difficulty | What Breaks |
|---|-----|-----------|-------------|
| 01 | Provider Not Healthy | ⭐ Easy | Wrong credentials secret |
| 02 | Composition Mismatch | ⭐⭐ Medium | API group doesn't match |
| 03 | Managed Resource Stuck | ⭐⭐ Medium | Cloud API error |
| 04 | XRD Schema Invalid | ⭐⭐⭐ Hard | OpenAPI schema rejects input |
| 05 | Patch Wrong | ⭐⭐⭐ Hard | Field path mapping incorrect |
| 06 | Provider Config Missing | ⭐⭐ Medium | ProviderConfig not found |
| 07 | Dependency Ordering | ⭐⭐⭐ Hard | VPC needed before subnet |
| 08 | Deletion Policy Orphan | ⭐⭐ Medium | Resources not cleaned up |
| 09 | External Name Conflict | ⭐⭐⭐ Hard | Name collision in cloud |
| 10 | Composition Revision | ⭐⭐⭐ Hard | Old revision still in use |

---

## 📖 Reference
- Docs: https://docs.crossplane.io/
- Marketplace: https://marketplace.upbound.io/
