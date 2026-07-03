## Solution: IAM Permission Denied

### Root Cause
Your application or CLI gets AccessDenied when calling AWS APIs. The IAM policy is missing required permissions or the resource ARN is wrong.

### Fix
Add the missing permission to the IAM policy. Ensure the Resource ARN matches. Check for explicit Deny in SCPs.

### Verification
Run the commands below to verify the fix works:
```bash
aws sts get-caller-identity
aws iam get-policy-version --policy-arn <arn> --version-id v1
aws iam simulate-principal-policy --policy-source-arn <arn> --action-names ec2:DescribeInstances
```
