# 📦 Kustomize Troubleshooting Labs

## 10 Real-World Broken Kustomize Scenarios

---

## 📚 What is Kustomize?

Kustomize lets you **customize Kubernetes YAML without templates**. Unlike Helm (which uses `{{ }}` templating), Kustomize uses **patching** — you keep the original YAML and apply changes on top.

### Kustomize vs Helm:
| | Kustomize | Helm |
|---|-----------|------|
| Approach | Patch original YAML | Template with `{{ }}` |
| Learning curve | Lower (just YAML) | Higher (Go templates) |
| Built into kubectl | ✅ `kubectl apply -k` | ❌ Separate CLI |
| Package manager | ❌ No | ✅ Charts + repos |
| Best for | Per-env overlays | Reusable packages |

### Core Pattern:
```
base/                         ← Shared, original YAML
├── deployment.yaml
├── service.yaml
└── kustomization.yaml        ← Lists resources

overlays/
├── dev/
│   ├── kustomization.yaml    ← References base + patches
│   └── replicas-patch.yaml   ← Change replicas to 1
├── staging/
│   └── kustomization.yaml
└── prod/
    ├── kustomization.yaml
    └── resources-patch.yaml  ← Change CPU/memory limits
```

---

## 🔑 Key Features

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:        # What to include
  - ../base

namePrefix: prod-         # Add prefix to all names
namespace: production     # Set namespace on all resources
commonLabels:             # Add labels to everything
  env: production

patches:                  # Modify resources
  - path: replicas-patch.yaml
    target:
      kind: Deployment
      name: myapp

configMapGenerator:       # Auto-create ConfigMaps
  - name: app-config
    files:
      - config.json

secretGenerator:          # Auto-create Secrets
  - name: db-creds
    envs:
      - .env.secret
```

---

## 📋 Labs

| # | Lab | Difficulty | What Breaks |
|---|-----|-----------|-------------|
| 01 | Missing Base | ⭐ Easy | Base directory path wrong |
| 02 | Patch Target Mismatch | ⭐⭐ Medium | Patch can't find resource |
| 03 | Name Prefix Breaking | ⭐⭐ Medium | References broken after prefix |
| 04 | Overlay Conflict | ⭐⭐ Medium | Multiple patches on same field |
| 05 | Generator Secret Wrong | ⭐⭐ Medium | File path doesn't exist |
| 06 | Component Not Found | ⭐⭐ Medium | Component path wrong |
| 07 | JSON Patch Invalid | ⭐⭐⭐ Hard | Wrong JSON patch operation |
| 08 | Namespace Transformer | ⭐⭐⭐ Hard | CRDs skipped by transformer |
| 09 | Replacement Broken | ⭐⭐⭐ Hard | Source/target field mismatch |
| 10 | Remote Base Unreachable | ⭐⭐ Medium | Git URL or ref wrong |

---

## 📖 Reference
- Docs: https://kustomize.io/
- kubectl: https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/
