# 🔧 DevOps Troubleshooting Labs

## 170+ Real-World Broken Scenarios for DevOps Engineers

---

## Overview

This repository is a collection of **intentionally broken** configurations and deployments across the entire DevOps toolchain. Each lab presents a real-world failure scenario that you must diagnose and fix using only the tool's CLI and your troubleshooting skills.

Whether it's a crashing Kubernetes pod, a failing Terraform plan, a misconfigured Nginx reverse proxy, or a broken CI/CD pipeline — these labs simulate the exact problems you'll encounter in production environments. No hand-holding, no multiple choice. Just you, a broken system, and your terminal.

---

## 🗂️ Tool Index

| # | Category | Labs | Directory | Status |
|---|----------|------|-----------|--------|
| 01 | Kubernetes | 20 | `kubernetes-labs/` | ✅ Available |
| 02 | Terraform | 15 | `terraform-labs/` | ✅ Available |
| 03 | Docker | 15 | `docker-labs/` | ✅ Available |
| 04 | Ansible | 15 | `ansible-labs/` | ✅ Available |
| 05 | Jenkins | 15 | `jenkins-labs/` | ✅ Available |
| 06 | ArgoCD | 15 | `argocd-labs/` | ✅ Available |
| 07 | Prometheus/Grafana | 15 | `prometheus-grafana-labs/` | ✅ Available |
| 08 | Helm | 15 | `helm-labs/` | ✅ Available |
| 09 | Linux/Networking | 15 | `linux-networking-labs/` | ✅ Available |
| 10 | Nginx/HAProxy | 15 | `nginx-haproxy-labs/` | ✅ Available |
| 11 | CI/CD Pipelines | 15 | `cicd-pipelines-labs/` | ✅ Available |

**Total: 170 labs across 11 categories**

---

## 🚀 Quick Start

### Deploy a single lab (Kubernetes example):
```bash
cd kubernetes-labs/lab-01-crashloopbackoff
./deploy.sh
```

### Deploy all Kubernetes labs:
```bash
cd kubernetes-labs
./deploy-all.sh
```

### Run a Terraform lab:
```bash
cd terraform-labs/lab-01-*
terraform init
terraform plan
# Observe the error, diagnose, and fix!
```

### Run a Docker lab:
```bash
cd docker-labs/lab-01-*
docker build -t broken-app .
docker run broken-app
# Observe the failure, diagnose, and fix!
```

### Run an Ansible lab:
```bash
cd ansible-labs/lab-01-*
ansible-playbook broken-playbook.yaml
# Observe the error, diagnose, and fix!
```

### Clean up all Kubernetes labs:
```bash
cd kubernetes-labs
./cleanup.sh
```

### Use master script for any category:
```bash
./master-deploy.sh docker
./master-cleanup.sh docker
```

---

## 📁 Directory Structure

```
devops-troubleshooting-labs/
├── README.md
├── master-deploy.sh
├── master-cleanup.sh
├── kubernetes-labs/                # Kubernetes troubleshooting labs (15)
├── terraform-labs/                 # Terraform troubleshooting labs
├── docker-labs/                    # Docker troubleshooting labs
├── ansible-labs/                   # Ansible troubleshooting labs
├── jenkins-labs/                   # Jenkins troubleshooting labs
├── argocd-labs/                    # ArgoCD troubleshooting labs
├── prometheus-grafana-labs/        # Prometheus/Grafana troubleshooting labs
├── helm-labs/                      # Helm troubleshooting labs
├── linux-networking-labs/          # Linux/Networking troubleshooting labs
├── nginx-haproxy-labs/             # Nginx/HAProxy troubleshooting labs
└── cicd-pipelines-labs/            # CI/CD Pipelines troubleshooting labs
```

---

## 📋 Prerequisites

| Tool | Required For | Install Guide |
|------|-------------|---------------|
| `kubectl` | Kubernetes labs | [kubernetes.io/docs](https://kubernetes.io/docs/tasks/tools/) |
| A K8s cluster (minikube/kind/k3s/EKS) | Kubernetes labs | [minikube.sigs.k8s.io](https://minikube.sigs.k8s.io/docs/start/) |
| `terraform` | Terraform labs | [terraform.io/downloads](https://www.terraform.io/downloads) |
| `docker` | Docker labs | [docs.docker.com](https://docs.docker.com/get-docker/) |
| `ansible` | Ansible labs | [docs.ansible.com](https://docs.ansible.com/ansible/latest/installation_guide/) |
| `jenkins` (or Docker) | Jenkins labs | [jenkins.io/download](https://www.jenkins.io/download/) |
| `argocd` CLI | ArgoCD labs | [argo-cd.readthedocs.io](https://argo-cd.readthedocs.io/en/stable/cli_installation/) |
| `helm` | Helm labs | [helm.sh/docs](https://helm.sh/docs/intro/install/) |
| `prometheus` / `grafana` | Monitoring labs | [prometheus.io](https://prometheus.io/download/) |
| Linux VM or container | Linux/Networking labs | Any Linux distribution |
| `nginx` / `haproxy` | Load balancer labs | `apt install nginx haproxy` |
| `git` + CI platform access | CI/CD labs | GitHub Actions / GitLab CI / Jenkins |

---

## 📊 Progress Tracker

Track your completion across all categories:

| Category | Completed | Total | Progress |
|----------|-----------|-------|----------|
| ☐ Kubernetes | _ /20 | 20 | ░░░░░░░░░░ |
| ☐ Terraform | _ /15 | 15 | ░░░░░░░░░░ |
| ☐ Docker | _ /15 | 15 | ░░░░░░░░░░ |
| ☐ Ansible | _ /15 | 15 | ░░░░░░░░░░ |
| ☐ Jenkins | _ /15 | 15 | ░░░░░░░░░░ |
| ☐ ArgoCD | _ /15 | 15 | ░░░░░░░░░░ |
| ☐ Prometheus/Grafana | _ /15 | 15 | ░░░░░░░░░░ |
| ☐ Helm | _ /15 | 15 | ░░░░░░░░░░ |
| ☐ Linux/Networking | _ /15 | 15 | ░░░░░░░░░░ |
| ☐ Nginx/HAProxy | _ /15 | 15 | ░░░░░░░░░░ |
| ☐ CI/CD Pipelines | _ /15 | 15 | ░░░░░░░░░░ |

---

## ⚔️ Rules of Engagement

1. **Don't look at the broken config files** before trying to diagnose — that's cheating!
2. Deploy the lab → investigate using only CLI tools → identify the root cause → fix it
3. Time yourself — an experienced DevOps engineer should solve most labs in under 10 minutes
4. Document your findings — write down what broke and how you fixed it
5. No Googling the answer for at least 5 minutes — trust your instincts first
6. If you're stuck, read the lab's README for hints before looking at the solution

---

## 💡 Tips

- **Start easy**: Begin with Kubernetes labs 01-02 or Docker labs as warm-ups
- **Read error messages carefully**: 90% of the answer is in the error output
- **Use describe and logs**: `kubectl describe`, `docker logs`, `terraform show` are your best friends
- **Check events**: `kubectl get events`, `journalctl`, and audit logs reveal the timeline
- **Think in layers**: Is it a config issue? A networking issue? A permissions issue? A resource issue?
- **Compare working vs broken**: If you have a working reference, diff against it
- **Follow the dependency chain**: Many failures cascade — find the root cause, not the symptom
- **Practice under pressure**: Set a timer to simulate on-call incident response

---

## 🤝 Contributing

Want to add more broken scenarios? PRs are welcome! Each lab should include:
- A `broken-*` config file with an intentional issue
- A `README.md` with hints (no spoilers!)
- A `solution/` directory with the fix and explanation

---

## 📜 License

MIT License — break things freely, fix them wisely.

---

Good luck, and happy troubleshooting! 🚀
