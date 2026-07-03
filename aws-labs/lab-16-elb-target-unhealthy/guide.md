# 📖 Detailed Guide: lab-16-elb-target-unhealthy

## Category: Networking

## Understanding the Problem
ALB targets all unhealthy: health check path wrong, SG blocking health check port

---

## 🖥️ AWS Console Steps (GUI)

### Step 1: Navigate to the Service
1. Open **AWS Console** → Search for **VPC/EC2**
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
ALB targets all unhealthy: health check path wrong, SG blocking health check port

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

### Create the broken state in AWS Console:

#### Step 1: Launch an EC2 instance with a web server
1. **EC2 → Launch instance**
2. Name: `web-server-lab`
3. AMI: Amazon Linux 2023
4. Instance type: t2.micro
5. Key pair: Create or select one
6. Network: Default VPC, Enable public IP
7. Security Group: Allow SSH (22) + HTTP (80)
8. User data (Advanced):
   ```bash
   #!/bin/bash
   yum install -y httpd
   echo "Hello from $(hostname)" > /var/www/html/index.html
   systemctl start httpd
   ```
9. Launch!

#### Step 2: Create Target Group with WRONG health check
1. **EC2 → Target Groups → Create target group**
2. Type: Instances
3. Name: `broken-tg`
4. Protocol: HTTP, Port: 80
5. Health check path: `/healthcheck` ← WRONG! (should be `/` or `/index.html`)
6. Click **Next** → Register your EC2 instance → Create

#### Step 3: Create ALB
1. **EC2 → Load Balancers → Create → Application Load Balancer**
2. Name: `broken-alb`
3. Scheme: Internet-facing
4. Listeners: HTTP:80
5. Select AZs (at least 2)
6. Security Group: Allow HTTP (80) from 0.0.0.0/0
7. Default action: Forward to `broken-tg`
8. Create!

#### Step 4: Observe the problem
1. Wait 2 minutes
2. **Target Groups → broken-tg → Targets tab**
3. You'll see: **Status: unhealthy** ❌
4. Reason: `Health checks failed with these codes: [404]`
5. The health check path `/healthcheck` returns 404 (doesn't exist!)

#### Step 5: Fix it
1. **Target Groups → broken-tg → Health checks → Edit**
2. Change path from `/healthcheck` to `/`
3. Save changes
4. Wait 30 seconds → Targets become **healthy** ✅

#### Step 6: Test the ALB
1. Copy the ALB DNS name (e.g., `broken-alb-123.us-east-1.elb.amazonaws.com`)
2. Open in browser → Should show "Hello from ip-xxx"

#### Step 7: Cleanup
1. Delete ALB → Delete Target Group → Terminate EC2
