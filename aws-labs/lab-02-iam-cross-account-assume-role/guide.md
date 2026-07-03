# 📖 Detailed Guide: Cross-Account AssumeRole

## Understanding the Problem
AssumeRole lets you access resources in ANOTHER AWS account. It fails when trust policy is wrong.

---

## 🖥️ AWS Console Steps

### Account B (the account you want to access):
1. **IAM → Roles** → Find the role (e.g., `CrossAccountDeployRole`)
2. Click **Trust relationships** tab → Click **Edit trust policy**
3. Ensure it trusts Account A:
   ```json
   {
     "Effect": "Allow",
     "Principal": {
       "AWS": "arn:aws:iam::111111111111:root"
     },
     "Action": "sts:AssumeRole",
     "Condition": {
       "StringEquals": {
         "sts:ExternalId": "my-secret-external-id"
       }
     }
   }
   ```

### Account A (the account calling AssumeRole):
1. **IAM → Users/Roles** → Find the caller
2. Ensure they have permission to call `sts:AssumeRole`:
   ```json
   {
     "Effect": "Allow",
     "Action": "sts:AssumeRole",
     "Resource": "arn:aws:iam::222222222222:role/CrossAccountDeployRole"
   }
   ```

---

## 💻 AWS CLI Steps

```bash
# Test AssumeRole:
aws sts assume-role \
  --role-arn arn:aws:iam::222222222222:role/CrossAccountDeployRole \
  --role-session-name my-session \
  --external-id my-secret-external-id

# Common errors:
# "is not authorized to perform: sts:AssumeRole" → Caller missing permission
# "Not authorized to perform sts:AssumeRole on resource" → Trust policy wrong

# Fix trust policy (in Account B):
aws iam update-assume-role-policy \
  --role-name CrossAccountDeployRole \
  --policy-document file://trust-policy.json
```

---

## 🧠 Key Concepts
- **Trust Policy** = WHO can assume this role (on the role itself, in target account)
- **Permission Policy** = WHAT the role can do once assumed
- **External ID** = Extra verification (prevents confused deputy attack)
- **Session duration** = Max time (default 1h, max 12h)
