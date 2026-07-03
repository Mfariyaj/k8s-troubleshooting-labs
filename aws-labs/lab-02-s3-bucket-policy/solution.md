## Solution: S3 Bucket Policy Conflict

### Root Cause
S3 bucket returns 403 Forbidden. The bucket policy and IAM policy conflict, or S3 Block Public Access is overriding permissions.

### Fix
Ensure bucket policy allows the IAM principal. Check that Block Public Access isn't overriding. Use Policy Simulator.

### Verification
Run the commands below to verify the fix works:
```bash
aws s3api get-bucket-policy --bucket my-bucket
aws s3api get-public-access-block --bucket my-bucket
aws s3api get-bucket-acl --bucket my-bucket
aws iam simulate-principal-policy --policy-source-arn <arn> --action-names s3:GetObject --resource-arns arn:aws:s3:::my-bucket/*
```
