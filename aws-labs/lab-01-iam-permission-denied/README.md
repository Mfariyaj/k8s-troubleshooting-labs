## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh`
2. Observe the error output
3. Diagnose the root cause
4. Apply the fix
5. Verify it works. Check `solution.md` if stuck

---

# IAM Permission Denied

## Difficulty: ⭐⭐ Medium

## 📚 What This Teaches
Your application or CLI gets AccessDenied when calling AWS APIs. The IAM policy is missing required permissions or the resource ARN is wrong.

## 🔧 Scenario
Your application or CLI gets AccessDenied when calling AWS APIs. The IAM policy is missing required permissions or the resource ARN is wrong.

## 💥 Error Output
```
An error occurred (AccessDeniedException) when calling the DescribeInstances operation: User: arn:aws:iam::123456789012:user/deploy-user is not authorized to perform: ec2:DescribeInstances on resource: * with an explicit deny in a service control policy
```

## 💡 Hints

<details><summary>Hint 1</summary>
Run 'aws sts get-caller-identity' to confirm which identity is making the call
</details>

<details><summary>Hint 2</summary>
Check the IAM policy attached: 'aws iam list-attached-user-policies --user-name deploy-user'
</details>

<details><summary>Hint 3</summary>
Add the missing permission to the IAM policy. Ensure the Resource ARN matches. Check for explicit Deny in SCPs.
</details>

## 🛠️ Useful Commands
```bash
aws sts get-caller-identity
aws iam get-policy-version --policy-arn <arn> --version-id v1
aws iam simulate-principal-policy --policy-source-arn <arn> --action-names ec2:DescribeInstances
```
