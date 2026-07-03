## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh`
2. Observe the error output
3. Diagnose the root cause
4. Apply the fix
5. Verify it works. Check `solution.md` if stuck

---

# S3 Bucket Policy Conflict

## Difficulty: ⭐⭐ Medium

## 📚 What This Teaches
S3 bucket returns 403 Forbidden. The bucket policy and IAM policy conflict, or S3 Block Public Access is overriding permissions.

## 🔧 Scenario
S3 bucket returns 403 Forbidden. The bucket policy and IAM policy conflict, or S3 Block Public Access is overriding permissions.

## 💥 Error Output
```
An error occurred (AccessDenied) when calling the GetObject operation: Access Denied
```

## 💡 Hints

<details><summary>Hint 1</summary>
Check bucket policy: aws s3api get-bucket-policy --bucket my-bucket
</details>

<details><summary>Hint 2</summary>
Check Block Public Access: aws s3api get-public-access-block --bucket my-bucket
</details>

<details><summary>Hint 3</summary>
Ensure bucket policy allows the IAM principal. Check that Block Public Access isn't overriding. Use Policy Simulator.
</details>

## 🛠️ Useful Commands
```bash
aws s3api get-bucket-policy --bucket my-bucket
aws s3api get-public-access-block --bucket my-bucket
aws s3api get-bucket-acl --bucket my-bucket
aws iam simulate-principal-policy --policy-source-arn <arn> --action-names s3:GetObject --resource-arns arn:aws:s3:::my-bucket/*
```
