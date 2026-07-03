# 📖 Detailed Guide: EKS Node Not Joining

## Understanding the Problem
EKS worker nodes show `NotReady` because the node's IAM role isn't mapped in the `aws-auth` ConfigMap.

---

## 🖥️ AWS Console Steps

### Step 1: Check node status
1. **EKS → Clusters → your-cluster → Compute** tab
2. Check **Node groups** — are they showing healthy?
3. Check the **EC2 instances** — are they running?

### Step 2: Check aws-auth ConfigMap
1. **CloudShell** or terminal with kubectl:
   ```bash
   kubectl get cm aws-auth -n kube-system -o yaml
   ```
2. Look for your node's IAM role ARN in `mapRoles`

### Step 3: Add missing role (Console method)
1. **EKS → Clusters → Access** tab
2. Or edit ConfigMap directly:
   ```bash
   kubectl edit cm aws-auth -n kube-system
   ```

---

## 💻 AWS CLI Steps

```bash
# Step 1: Get node group role ARN
aws eks describe-nodegroup \
  --cluster-name my-cluster \
  --nodegroup-name my-nodes \
  --query 'nodegroup.nodeRole'
# Output: "arn:aws:iam::123456789012:role/eks-node-role"

# Step 2: Check current aws-auth
kubectl get cm aws-auth -n kube-system -o yaml

# Step 3: If role is missing, add it:
kubectl edit cm aws-auth -n kube-system

# Add under mapRoles:
# - rolearn: arn:aws:iam::123456789012:role/eks-node-role
#   username: system:node:{{EC2PrivateDNSName}}
#   groups:
#     - system:bootstrappers
#     - system:nodes

# Step 4: Verify nodes join
kubectl get nodes -w
# Nodes should become Ready within 1-2 minutes
```

---

## 🧠 How EKS Node Auth Works
```
EC2 Instance boots → Runs bootstrap.sh → Calls EKS API with IAM role
    │
    ▼
EKS API Server checks aws-auth ConfigMap:
  "Is this IAM role ARN listed in mapRoles?"
    │
    ├── YES → Node joins as system:node, gets bootstrapper group
    │
    └── NO → Node rejected, stays NotReady
```

### Common Mistakes:
| Mistake | Fix |
|---------|-----|
| Role ARN not in aws-auth | Add the node role ARN to mapRoles |
| Wrong ARN format (path included) | Use `role/name` not `role/path/name` |
| Used instance profile ARN instead of role ARN | Use the ROLE ARN, not instance profile |
| Node AMI too old | Use EKS-optimized AMI matching cluster version |
