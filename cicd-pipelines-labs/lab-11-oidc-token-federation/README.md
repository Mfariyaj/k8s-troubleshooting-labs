## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (creates a git repo with broken workflow)
2. Review the broken workflow YAML (.github/workflows/ or .gitlab-ci.yml)
3. Identify the syntax errors, logic issues, or misconfiguration
4. Fix the workflow file
5. Validate with: `actionlint` (GitHub Actions) or CI Lint API (GitLab)
6. Check `solution.md` if stuck

---

# Lab 11: GitHub Actions OIDC Token Federation to AWS — AccessDenied

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your platform team has implemented GitHub Actions OIDC federation to eliminate long-lived AWS credentials from CI/CD pipelines. The workflow uses `aws-actions/configure-aws-credentials` with OIDC to assume an IAM role, but every run fails with:

```
Error: Could not assume role with OIDC: AccessDenied
```

The IAM role was provisioned via Terraform and the workflow was recently migrated from a different repository. Deployments are completely blocked and the team is pressuring you to revert to static credentials. You need to fix the OIDC federation without compromising the zero-trust security posture.

## Error Output

```
Run aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::123456789012:role/github-actions-deploy
    aws-region: us-east-1
    role-session-name: GitHubActions
    role-duration-seconds: 7200

Error: Could not assume role with OIDC: Not authorized to perform sts:AssumeRoleWithWebIdentity

Detailed error:
An error occurred (AccessDenied) when calling the AssumeRoleWithWebIdentity operation:
Not authorized to perform sts:AssumeRoleWithWebIdentity on resource:
arn:aws:iam::123456789012:role/github-actions-deploy with web identity token.

GitHub OIDC Token Claims:
  iss: https://token.actions.githubusercontent.com
  aud: sigstore
  sub: repo:acme-corp/infra-deploy:ref:refs/heads/main
```

```
# Terraform plan output for role:
Plan: 1 to add, 0 to change, 0 to destroy.

Warning: Role maximum session duration (3600s) is less than requested duration (7200s)
```

## Your Task

Identify and fix ALL issues preventing the OIDC federation from working:
1. Why is the audience claim wrong?
2. Why does the subject claim not match the trust policy condition?
3. Why is the condition operator preventing valid matches?
4. Why can't the workflow generate an OIDC token?
5. Why does the session duration cause failures?

## Hints

<details>
<summary>Hint 1</summary>
The default audience for `aws-actions/configure-aws-credentials` is `sts.amazonaws.com`, not `sigstore`. Check the trust policy's `token.actions.githubusercontent.com:aud` condition. Also check if the workflow has the `id-token: write` permission — without it, the OIDC token cannot be generated at all.
</details>

<details>
<summary>Hint 2</summary>
The subject claim format in the trust policy uses `repo:owner/repo:ref:refs/heads/main` but the actual token uses `repo:acme-corp/infra-deploy:ref:refs/heads/main`. Check if the owner/repo in the trust policy matches the actual repository. Also, `StringEquals` won't work if you need wildcard matching for branches — but for exact branch matching, the subject format itself may be wrong.
</details>

<details>
<summary>Hint 3</summary>
The IAM role's `MaxSessionDuration` is set to 3600 seconds (1 hour) but the workflow requests 7200 seconds (2 hours). AWS will deny the assume-role call if the requested duration exceeds the role's maximum. Also verify the trust policy uses the correct federated principal ARN format.
</details>

## Useful Commands

```bash
# Examine the broken workflow
cat .github/workflows/broken-oidc.yml

# Examine the Terraform IAM role configuration
cat terraform/oidc-role.tf

# Validate GitHub OIDC token claims (in a running workflow)
curl -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
  "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=sts.amazonaws.com" | jq .

# Check IAM role trust policy
aws iam get-role --role-name github-actions-deploy --query 'Role.AssumeRolePolicyDocument'

# Check role max session duration
aws iam get-role --role-name github-actions-deploy --query 'Role.MaxSessionDuration'

# Decode a JWT token (without verification)
echo "$TOKEN" | cut -d. -f2 | base64 -d 2>/dev/null | jq .

# List OIDC providers in AWS account
aws iam list-open-id-connect-providers

# Get OIDC provider details
aws iam get-open-id-connect-provider --open-id-connect-provider-arn \
  arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com

# Verify the audience list for the OIDC provider
aws iam get-open-id-connect-provider --open-id-connect-provider-arn \
  arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com \
  --query 'ClientIDList'

# Simulate the assume role call
aws sts assume-role-with-web-identity \
  --role-arn arn:aws:iam::123456789012:role/github-actions-deploy \
  --role-session-name test \
  --web-identity-token "$TOKEN" \
  --duration-seconds 3600

# Check CloudTrail for AssumeRoleWithWebIdentity failures
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRoleWithWebIdentity \
  --query 'Events[].{Time:EventTime,Error:CloudTrailEvent}' | jq .

# Terraform plan to see current state
cd terraform && terraform plan
```

## What You'll Learn

- GitHub Actions OIDC token structure and claims
- AWS IAM trust policy conditions for web identity federation
- StringEquals vs StringLike condition operators
- OIDC audience and subject claim validation
- IAM role session duration limits
- Debugging STS AssumeRoleWithWebIdentity failures
