# Lab 11: Cross-Account Assume Role Failure

## Difficulty: 🔴 Expert

## Estimated Time: 20-30 minutes

---

## Scenario

Your platform engineering team manages infrastructure across multiple AWS accounts using Terraform. The setup uses a **source account** (111122223333) where Terraform runs, and a **target account** (444455556666) where production resources are deployed.

A junior engineer set up the cross-account IAM role and trust policy, but `terraform plan` fails when trying to assume the role in the target account. The error manifests as an `AccessDenied` during provider initialization.

Multiple issues are stacked: trust policy misconfiguration, session duration conflicts, external ID mismatches, and a permission boundary that's too restrictive for the intended operations.

---

## Error Output

```
$ terraform init
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.31.0...
- Installed hashicorp/aws v5.31.0 (signed by HashiCorp)
Terraform has been successfully initialized!

$ terraform plan

╷
│ Error: configuring Terraform AWS Provider: assuming IAM Role (arn:aws:iam::444455556666:role/TerraformCrossAccountRole): operation error STS: AssumeRole, https response error StatusCode: 403, RequestID: a1b2c3d4-5678-90ab-cdef-EXAMPLE11111, api error AccessDenied: User: arn:aws:iam::111122223333:user/terraform-ci is not authorized to perform: sts:AssumeRole on resource: arn:aws:iam::444455556666:role/TerraformCrossAccountRole
│ 
│   with provider["registry.terraform.io/hashicorp/aws"].target_account,
│   on providers.tf line 20, in provider "aws":
│   20: provider "aws" {
│ 
╵

# After fixing the source account policy, the next error:
$ terraform plan

╷
│ Error: configuring Terraform AWS Provider: assuming IAM Role (arn:aws:iam::444455556666:role/TerraformCrossAccountRole): operation error STS: AssumeRole, https response error StatusCode: 403, RequestID: a1b2c3d4-5678-90ab-cdef-EXAMPLE22222, api error AccessDenied: User: arn:aws:iam::111122223333:user/terraform-ci is not authorized to perform: sts:AssumeRole on resource: arn:aws:iam::444455556666:role/TerraformCrossAccountRole. Reason: the trust policy does not allow the caller to assume the role
│ 
│   with provider["registry.terraform.io/hashicorp/aws"].target_account,
│   on providers.tf line 20, in provider "aws":
│   20: provider "aws" {
│ 
╵

# After fixing trust policy principal, next error about external ID:
$ terraform plan

╷
│ Error: configuring Terraform AWS Provider: assuming IAM Role (arn:aws:iam::444455556666:role/TerraformCrossAccountRole): operation error STS: AssumeRole, https response error StatusCode: 403, RequestID: a1b2c3d4-5678-90ab-cdef-EXAMPLE33333, api error AccessDenied: ... Reason: external ID does not match what is required by the role's trust policy
│ 
╵

# After fixing external ID, session duration error:
$ terraform plan

╷
│ Error: configuring Terraform AWS Provider: assuming IAM Role (arn:aws:iam::444455556666:role/TerraformCrossAccountRole): operation error STS: AssumeRole, https response error StatusCode: 400, RequestID: a1b2c3d4-5678-90ab-cdef-EXAMPLE44444, api error ValidationError: The requested DurationSeconds exceeds the MaxSessionDuration set for this role.
│ 
╵

# After all assume role issues fixed, permission boundary blocks operations:
$ terraform apply

╷
│ Error: creating Amazon S3 (Simple Storage) Bucket (company-data-lake-444455556666): operation error S3: CreateBucket, https response error StatusCode: 403, RequestID: EXAMPLE55555, api error AccessDenied: Access Denied
│ 
│   with aws_s3_bucket.cross_account_data,
│   on main.tf line 18, in resource "aws_s3_bucket" "cross_account_data":
│   18: resource "aws_s3_bucket" "cross_account_data" {
│ 
╵
```

---

## Hints

<details>
<summary>Hint 1</summary>
Compare the account ID in the trust policy principal with the actual source account ID. Also check what Action the trust policy allows — is `sts:TagSession` sufficient to assume a role?
</details>

<details>
<summary>Hint 2</summary>
The external ID in providers.tf ("TerraformExternal2025") must exactly match the Condition in the trust policy ("TerraformExternal2024"). Also check if the session duration requested (12h = 43200s) exceeds the role's max_session_duration (3600s).
</details>

<details>
<summary>Hint 3</summary>
The permission boundary restricts the role to EC2 and IAM read actions only. The role policy grants S3 and DynamoDB access, but effective permissions are the INTERSECTION of the role policy and the permission boundary. Also check the source account's AssumeRole policy — does the Resource ARN match the actual role name?
</details>

---

## Troubleshooting Commands

```bash
# Check current identity
aws sts get-caller-identity

# Try to assume the role manually
aws sts assume-role \
  --role-arn "arn:aws:iam::444455556666:role/TerraformCrossAccountRole" \
  --role-session-name "test-session" \
  --external-id "TerraformExternal2025" \
  --duration-seconds 3600

# Inspect the trust policy of the target role
aws iam get-role --role-name TerraformCrossAccountRole --profile target-account

# Check role's max session duration
aws iam get-role --role-name TerraformCrossAccountRole --profile target-account \
  --query 'Role.MaxSessionDuration'

# List attached policies and permission boundary
aws iam get-role --role-name TerraformCrossAccountRole --profile target-account \
  --query 'Role.PermissionsBoundary'

# Get the permission boundary policy document
aws iam get-policy-version --policy-arn <boundary-policy-arn> \
  --version-id v1 --profile target-account

# Simulate the assumed role's effective permissions
aws iam simulate-principal-policy \
  --policy-source-arn "arn:aws:iam::444455556666:role/TerraformCrossAccountRole" \
  --action-names "s3:CreateBucket" "dynamodb:CreateTable" \
  --profile target-account

# Check if source account has permission to assume the role
aws iam simulate-principal-policy \
  --policy-source-arn "arn:aws:iam::111122223333:user/terraform-ci" \
  --action-names "sts:AssumeRole" \
  --resource-arns "arn:aws:iam::444455556666:role/TerraformCrossAccountRole"

# Enable Terraform debug logging
TF_LOG=DEBUG terraform plan 2>&1 | grep -i "assume\|error\|denied"

# Check CloudTrail for AssumeRole events
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRole \
  --max-results 5

# Validate the terraform configuration
terraform validate

# Show provider configuration
terraform providers
```

---

## What to Fix

You need to identify and correct ALL of the following issues:
1. Source account IAM policy Resource ARN mismatch
2. Trust policy principal has wrong account ID
3. Trust policy Action should be `sts:AssumeRole` not `sts:TagSession`
4. External ID mismatch between provider and trust policy
5. Session duration exceeds role's max_session_duration
6. Permission boundary blocks S3 and DynamoDB operations needed by Terraform
