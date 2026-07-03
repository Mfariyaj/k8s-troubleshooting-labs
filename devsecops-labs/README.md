# 🛡️ DevSecOps Troubleshooting Labs

## 10 Real-World Security Broken Scenarios

---

## 📚 What is DevSecOps?

DevSecOps = **Security integrated into every stage of DevOps**, not bolted on at the end.

### The Shift-Left Approach:
```
Traditional: Code → Build → Test → Deploy → [Security Check] → Production
                                                    ↑ Too late! Bug already deployed

DevSecOps:   Code → [SAST] → Build → [Image Scan] → [Policy] → Deploy → [Runtime]
                ↑ Early!        ↑ Before push!       ↑ Admission!    ↑ Always watching!
```

---

## 🏗️ DevSecOps Pipeline

```
┌──────────┐  ┌───────────┐  ┌──────────┐  ┌───────────┐  ┌──────────┐
│  Code    │  │   Build   │  │  Deploy  │  │ Admission │  │ Runtime  │
│          │  │           │  │          │  │           │  │          │
│ SonarQube│  │   Trivy   │  │  Cosign  │  │    OPA    │  │  Falco   │
│ Semgrep  │  │   Snyk    │  │ Notary   │  │ Kyverno   │  │ Sysdig   │
│ gitleaks │  │ Grype     │  │          │  │           │  │ Tetragon │
└──────────┘  └───────────┘  └──────────┘  └───────────┘  └──────────┘
    SAST         SCA/Image      Supply        Policy         Threat
  (static)      Scanning       Chain         Enforce        Detection
```

---

## 🔑 Key Tools

| Tool | Stage | What It Does |
|------|-------|-------------|
| **SonarQube** | Code | Static analysis (bugs, vulnerabilities, code smells) |
| **Trivy** | Build | Scan container images + IaC for CVEs |
| **Snyk** | Code+Build | Dependency vulnerabilities + fixes |
| **Cosign** | Push | Sign container images (verify supply chain) |
| **OPA/Gatekeeper** | Admission | Block non-compliant K8s resources |
| **Kyverno** | Admission | K8s-native policy engine |
| **Falco** | Runtime | Detect suspicious syscalls in containers |
| **gitleaks** | Pre-commit | Detect secrets in git commits |

---

## 📋 Labs

| # | Lab | Difficulty | What You'll Learn |
|---|-----|-----------|-------------------|
| 01 | Trivy Scan Failures | ⭐ Easy | Container image scanning, CVE databases |
| 02 | SonarQube Quality Gate | ⭐⭐ Medium | Quality gates, coverage thresholds |
| 03 | Secret Scanning Bypass | ⭐⭐ Medium | Pre-commit hooks, gitleaks |
| 04 | Container Image Vuln | ⭐⭐ Medium | Base image selection, patching |
| 05 | OPA Policy Violation | ⭐⭐⭐ Hard | Rego language, constraints |
| 06 | RBAC Overpermissioned | ⭐⭐ Medium | Least privilege, audit |
| 07 | Network Policy Missing | ⭐⭐ Medium | Zero trust, microsegmentation |
| 08 | Supply Chain Attack | ⭐⭐⭐ Hard | Image signing, provenance |
| 09 | Runtime Security Alert | ⭐⭐⭐ Hard | Falco rules, syscall monitoring |
| 10 | Compliance Drift | ⭐⭐⭐ Hard | CIS benchmarks, kube-bench |

---

## 📖 Reference
- Trivy: https://aquasecurity.github.io/trivy/
- OPA: https://www.openpolicyagent.org/docs/
- Falco: https://falco.org/docs/
- CIS Benchmarks: https://www.cisecurity.org/benchmark/kubernetes
