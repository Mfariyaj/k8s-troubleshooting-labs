# 📖 Detailed Guide: IAM Permission Denied

## Understanding the Problem

When you see `AccessDenied`, it means the **IAM principal** (user/role) making the API call does NOT have the required **permission** for that specific **action** on that specific **resource**.

---

## 🖥️ AWS Console Steps (GUI)

### Step 1: Identify WHO is making the call
1. Open **AWS Console** → **IAM** → **Users** or **Roles**
2. Find the user/role that got the error
3. Click on it → Look at **Permissions** tab

### Step 2: Check what permissions they have
1. In the Permissions tab, click each **Policy name**
2. Click **JSON** tab to see the raw policy
3. Look for the action that was denied (e.g., `ec2:DescribeInstances`)

### Step 3: Check for explicit Deny
1. Look for any policy with `"Effect": "Deny"` — these ALWAYS win
2. Check **Permission boundaries** (if set, it limits maximum permissions)
3. Check **Organizations → SCPs** (Service Control Policies) — org-level deny

### Step 4: Fix the permission
1. Go to **IAM → Policies** → Click the policy → **Edit**
2. Add the missing permission:
   ```json
   {
     "Effect": "Allow",
     "Action": "ec2:DescribeInstances",
     "Resource": "*"
   }
   ```
3. Click **Review** → **Save changes**

### Step 5: Verify
1. Wait 30 seconds (IAM changes propagate)
2. Try the API call again — should work now

---

## 💻 AWS CLI Steps

```bash
# Step 1: Who am I?
aws sts get-caller-identity
# Output:
# {
#   "UserId": "AIDA...",
#   "Account": "123456789012",
#   "Arn": "arn:aws:iam::123456789012:user/deploy-user"
# }

# Step 2: What policies are attached?
aws iam list-attached-user-policies --user-name deploy-user
# Output:
# {
#   "AttachedPolicies": [
#     { "PolicyName": "DeployPolicy", "PolicyArn": "arn:aws:iam::123456789012:policy/DeployPolicy" }
#   ]
# }

# Step 3: Read the policy content
aws iam get-policy --policy-arn arn:aws:iam::123456789012:policy/DeployPolicy
# Get the version ID, then:
aws iam get-policy-version \
  --policy-arn arn:aws:iam::123456789012:policy/DeployPolicy \
  --version-id v1

# Step 4: Simulate the permission (test without actually calling)
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::123456789012:user/deploy-user \
  --action-names ec2:DescribeInstances
# If "EvalDecision": "implicitDeny" → permission missing!

# Step 5: Add the missing permission
cat > add-permission.json << 'POLICY'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:DescribeInstances",
      "Resource": "*"
    }
  ]
}
POLICY

aws iam put-user-policy \
  --user-name deploy-user \
  --policy-name EC2ReadAccess \
  --policy-document file://add-permission.json

# Step 6: Verify
aws ec2 describe-instances  # Should work now!
```

---

## 🧠 Key Concepts

### IAM Policy Evaluation Logic:
```
1. By default: EVERYTHING is DENIED (implicit deny)
2. If any policy has "Effect": "Allow" for the action → ALLOWED
3. BUT if ANY policy has "Effect": "Deny" → DENIED (deny always wins)
4. Permission boundary limits maximum possible permissions
5. SCP limits what the entire account can do
```

### Common Mistakes:
| Mistake | Example | Fix |
|---------|---------|-----|
| Wrong Resource ARN | `arn:aws:s3:::mybucket` (bucket) vs `arn:aws:s3:::mybucket/*` (objects) | Use correct ARN format |
| Missing region in ARN | `arn:aws:ec2::123:instance/*` | Add region: `arn:aws:ec2:us-east-1:123:instance/*` |
| Action typo | `ec2:DescribeInstance` (missing 's') | Use `ec2:DescribeInstances` |
| Condition blocking | `aws:SourceIp` only allows office IP | Remove condition or add VPN IP |

---

## 📖 Reference
- IAM Policy Evaluation: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html
- IAM Actions Reference: https://docs.aws.amazon.com/service-authorization/latest/reference/
- Policy Simulator: https://policysim.aws.amazon.com/
