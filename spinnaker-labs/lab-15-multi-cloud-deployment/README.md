## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (copies broken config to workspace)
2. Upload pipeline: `spin pipeline save --file pipeline.json`
3. Execute: `spin pipeline execute --name <pipeline> --application <app>`
4. Check Spinnaker UI for execution errors
5. Fix the pipeline JSON or service config
6. Check `solution.md` if stuck

---

# Lab 15: Multi-Cloud Deployment — K8s + AWS Cross-Cloud Failure

## Difficulty: 🟣 Expert

---

## 📚 What You'll Learn

Spinnaker's **multi-cloud** capability allows a single pipeline to deploy to multiple cloud providers. A common pattern is:

1. Build container → Deploy to Kubernetes (staging)
2. Bake AMI → Deploy to AWS EC2 (production)
3. Or: Deploy to K8s in one account AND AWS in another

For AWS provider accounts, Spinnaker needs:
- **Managing account**: Has the base IAM credentials (Clouddriver runs as this)
- **Managed accounts**: Other AWS accounts accessed via AssumeRole
- **IAM Role chain**: Managing account → assumes role in → Managed account

IAM setup for cross-account:
```
Managing Account (111111111111):
  Role: SpinnakerManaging
  Policy: sts:AssumeRole on arn:aws:iam::222222222222:role/SpinnakerManaged

Managed Account (222222222222):
  Role: SpinnakerManaged
  Trust Policy: Allow 111111111111 to AssumeRole
  Policy: ec2:*, autoscaling:*, elasticloadbalancing:*
```

Common multi-cloud failures:
- AWS account not added to Clouddriver
- IAM AssumeRole policy missing or wrong ARN
- Trust relationship not configured on target account role
- Deployment timeout because security group / VPC doesn't exist
- Region mismatch between accounts

---

## 🔧 Scenario

A pipeline deploys to both Kubernetes and AWS EC2, but the AWS portion fails:

1. The Clouddriver AWS account configuration has an AssumeRole ARN with wrong account ID (`000000000000` placeholder)
2. The pipeline references AWS account `aws-production` but it's configured as `aws-prod` in Clouddriver
3. The deployment timeout is set to 60 seconds, but cross-account AssumeRole + ASG creation takes longer

---

## 💥 Expected Error Output

```
Stage: Deploy to AWS
Status: TERMINAL (Failed)

Errors:
  - Could not find account 'aws-production' in Clouddriver.
    Available accounts: [my-k8s-account, aws-prod]
    
  - com.amazonaws.services.securitytoken.model.AWSSecurityTokenServiceException:
    User: arn:aws:iam::111111111111:role/SpinnakerManaging is not authorized 
    to perform: sts:AssumeRole on resource: 
    arn:aws:iam::000000000000:role/SpinnakerManaged
    (Service: AWSSecurityTokenService; Status Code: 403; 
     Error Code: AccessDenied)
     
  - Deployment timed out after 60 seconds waiting for ASG to reach 
    desired capacity. Consider increasing the timeout.
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>
Check the Clouddriver AWS account name. The pipeline references `aws-production` but what name was used when adding the account? Look at clouddriver-local.yml for the actual account names.
</details>

<details>
<summary>Hint 2 (Moderate)</summary>
The AssumeRole ARN contains a placeholder AWS account ID `000000000000`. This needs to be the real 12-digit account ID of the managed (target) account. Check aws-account.json for details.
</details>

<details>
<summary>Hint 3 (Strong)</summary>
Three fixes: 1) Change pipeline account reference from `aws-production` to `aws-prod`, 2) Fix the AssumeRole ARN from `arn:aws:iam::000000000000:role/SpinnakerManaged` to use the real account ID, 3) Increase deployment timeout from 60 to 300 seconds.
</details>

---

## 🛠️ Useful Commands

```bash
# List all accounts in Clouddriver
curl http://localhost:8084/credentials | jq '.[].name'

# Check AWS account configuration
hal config provider aws account list
hal config provider aws account get aws-prod

# Test AssumeRole
aws sts assume-role \
  --role-arn arn:aws:iam::222222222222:role/SpinnakerManaged \
  --role-session-name test-session

# Check Clouddriver for AWS errors
kubectl logs -n spinnaker spin-clouddriver-xxx | grep -i "aws\|assume\|403"

# Verify AWS account connectivity
curl http://localhost:7002/cache/aws/accounts | jq .
```

---

## 📖 References

- https://spinnaker.io/docs/setup/install/providers/aws/
- https://spinnaker.io/docs/setup/install/providers/aws/aws-concepts/
- https://spinnaker.io/docs/setup/install/providers/aws/aws-ec2/
- https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html

---

## 🏁 Success Criteria

- Pipeline can deploy to both Kubernetes and AWS accounts
- AssumeRole succeeds (no AccessDenied)
- AWS ASG is created with desired capacity
- Deployment completes within the configured timeout
