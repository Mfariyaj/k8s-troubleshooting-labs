# 📖 Detailed Guide: lab-25-lambda-timeout-vpc

## Category: Serverless

## Understanding the Problem
Lambda timeout: deployed in VPC without NAT, can't reach DynamoDB

---

## 🖥️ AWS Console Steps (GUI)

### Step 1: Navigate to the Service
1. Open **AWS Console** → Search for **Lambda/API GW**
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
Lambda timeout: deployed in VPC without NAT, can't reach DynamoDB

Always check:
1. **IAM permissions** (do I have access?)
2. **Security Groups** (can traffic reach the target?)
3. **Route Tables** (does the network path exist?)
4. **Service configuration** (is the service configured correctly?)

---

## 📖 Reference
- AWS Docs: https://docs.aws.amazon.com/
- Troubleshooting: https://repost.aws/knowledge-center

---

## 🎮 Console Practice Lab (Do This Yourself!)

### Create Lambda that times out in VPC:

#### Step 1: Create a Lambda function in VPC
1. **Lambda → Create function**
2. Name: `vpc-timeout-test`
3. Runtime: Python 3.12
4. **Advanced settings → Enable VPC**
5. Select your VPC
6. Select a **PRIVATE subnet** (one WITHOUT NAT Gateway)
7. Select a Security Group
8. Create function

#### Step 2: Add code that needs internet
```python
import urllib.request

def lambda_handler(event, context):
    # This needs internet access!
    response = urllib.request.urlopen('https://api.github.com', timeout=5)
    return {'statusCode': 200, 'body': response.read().decode()}
```
1. Paste this in the **Code** tab
2. Click **Deploy**

#### Step 3: Test and observe timeout
1. Click **Test** → Create test event (any name, empty JSON `{}`)
2. Click **Test**
3. ❌ Result: **Task timed out after 3.00 seconds**
4. The Lambda can't reach the internet because the private subnet has no NAT!

#### Step 4: Fix — Add NAT Gateway
1. **VPC → NAT Gateways → Create**
2. Select a PUBLIC subnet → Allocate Elastic IP → Create
3. **VPC → Route Tables** → Find the PRIVATE subnet's route table
4. Add route: `0.0.0.0/0` → Target: your new NAT Gateway

#### Step 5: Verify
1. Go back to Lambda → Test again
2. ✅ Should now return GitHub API response!
3. (If still timeout, wait 1 minute for route to propagate)

#### Step 6: Cleanup
1. Delete Lambda → Delete NAT Gateway → Release Elastic IP
