# 🔧 Terraform Troubleshooting Labs

## 10 Real-World Broken Terraform Configurations for DevOps Engineers

These labs contain **intentionally broken** Terraform configurations. Your job is to diagnose and fix each issue using Terraform CLI commands, error messages, and your understanding of Terraform internals.

---

## Prerequisites
- Terraform CLI installed (v1.5+)
- AWS CLI configured (or mock credentials for simulation)
- Basic to advanced Terraform knowledge
- Understanding of Terraform state, backends, and providers

---

## Lab Index

| # | Lab | Scenario | Difficulty |
|---|-----|----------|------------|
| 01 | [State Lock Conflict](lab-01-state-lock-conflict/) | Stale DynamoDB lock blocks operations | ⭐ |
| 02 | [Provider Version Mismatch](lab-02-provider-version-mismatch/) | Lock file hash doesn't match constraint | ⭐ |
| 03 | [Dependency Cycle](lab-03-dependency-cycle/) | Circular references between resources | ⭐⭐ |
| 04 | [Backend Bootstrap](lab-04-backend-bootstrap/) | Chicken-and-egg: backend bucket in same config | ⭐⭐ |
| 05 | [Module Source Not Found](lab-05-module-source-not-found/) | Wrong registry URL and impossible version | ⭐⭐ |
| 06 | [Variable Validation](lab-06-variable-validation/) | Type mismatch and validation failures | ⭐⭐ |
| 07 | [State Drift](lab-07-state-drift/) | Manual AWS console changes cause plan chaos | ⭐⭐⭐ |
| 08 | [Workspace Collision](lab-08-workspace-collision/) | Two workspaces sharing same state path | ⭐⭐⭐ |
| 09 | [Provisioner Failure](lab-09-provisioner-failure/) | Tainted resource from failed remote-exec | ⭐⭐⭐ |
| 10 | [Data Source Race Condition](lab-10-data-source-race/) | Data source reads before resource exists | ⭐⭐⭐ |

---

## How to Use

### Deploy a single lab:
```bash
cd lab-01-state-lock-conflict
./deploy.sh
```

### Deploy ALL labs at once:
```bash
./deploy-all.sh
```

### Clean up ALL labs:
```bash
./cleanup-all.sh
```

---

## Difficulty Guide

| Rating | Level | Description |
|--------|-------|-------------|
| ⭐ | Beginner | Common issues with clear error messages |
| ⭐⭐ | Intermediate | Requires understanding Terraform internals |
| ⭐⭐⭐ | Advanced | Complex state/runtime issues, multiple possible solutions |

---

## Tips
- Start with the easier labs (01-02) as warm-up
- Read the README in each lab folder for hints and expected error output
- Use `terraform validate`, `terraform plan`, and error messages as your primary tools
- Think about Terraform's execution model: init → plan → apply
- State management issues are the most common real-world problems
- Don't look at the broken configs before deploying — diagnose from error messages first!

---

## Rules
1. **Don't look at the solution** before trying to diagnose (that's cheating!)
2. Deploy the lab → investigate using Terraform CLI → identify the issue → fix it
3. Time yourself — an experienced DevOps engineer should solve most in under 15 minutes
4. Document your findings — write down what broke and how you fixed it
5. No Googling for at least 5 minutes — trust your instincts first

---

## Lab Completion Tracker

| # | Lab | Status |
|---|-----|--------|
| 01 | State Lock Conflict | ☐ |
| 02 | Provider Version Mismatch | ☐ |
| 03 | Dependency Cycle | ☐ |
| 04 | Backend Bootstrap | ☐ |
| 05 | Module Source Not Found | ☐ |
| 06 | Variable Validation | ☐ |
| 07 | State Drift | ☐ |
| 08 | Workspace Collision | ☐ |
| 09 | Provisioner Failure | ☐ |
| 10 | Data Source Race Condition | ☐ |

---

Good luck, and happy troubleshooting! 🚀
