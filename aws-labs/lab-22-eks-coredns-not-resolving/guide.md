# 📖 Detailed Guide: lab-22-eks-coredns-not-resolving

## Category: EKS & Containers

## Understanding the Problem
CoreDNS pods CrashLoop after node scale: IP exhaustion in subnet

---

## 🖥️ AWS Console Steps (GUI)

### Step 1: Navigate to the Service
1. Open **AWS Console** → Search for **EKS**
2. Find the resource mentioned in the error
3. Check its **configuration/settings**

### Step 2: Identify the Misconfiguration
1. Compare current config with expected config
2. Check **Security Groups / IAM Policies / Route Tables** (as applicable)
3. Check **CloudWatch Logs** for error details

### Step 3: Apply the Fix
1. Edit the misconfigured resource
2. Save changes
3. Wait for propagation (30s-2min for IAM, instant for SG)

### Step 4: Verify
1. Retry the failing operation
2. Check CloudWatch metrics/logs for success
3. Confirm end-to-end connectivity

---

## 💻 AWS CLI Steps

```bash
# Step 1: Identify the problem
aws sts get-caller-identity
# Check relevant service:
# aws ec2 describe-... / aws iam get-... / aws eks describe-... / aws rds describe-...

# Step 2: Diagnose
# Check logs:
aws logs filter-log-events --log-group-name <group>
# Check configs:
aws ec2 describe-security-groups --group-ids <sg>
aws iam get-policy-version --policy-arn <arn> --version-id v1

# Step 3: Fix
# Apply the correct configuration
# (specific commands depend on the issue - see solution.md)

# Step 4: Verify
# Retry the operation that was failing
```

---

## 🧠 Key Takeaway
CoreDNS pods CrashLoop after node scale: IP exhaustion in subnet

Always check:
1. **IAM permissions** (do I have access?)
2. **Security Groups** (can traffic reach the target?)
3. **Route Tables** (does the network path exist?)
4. **Service configuration** (is the service configured correctly?)

---

## 📖 Reference
- AWS Docs: https://docs.aws.amazon.com/
- Troubleshooting: https://repost.aws/knowledge-center
