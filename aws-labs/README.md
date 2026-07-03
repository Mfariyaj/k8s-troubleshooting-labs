# ☁️ AWS Troubleshooting Labs

## 10 Real-World AWS Broken Scenarios

---

## 📚 What These Labs Cover

AWS is the most used cloud platform. These labs simulate the **real errors** you'll face daily:
- IAM permission denied (the #1 AWS headache)
- VPC networking (can't reach internet, can't connect)
- EKS cluster issues (nodes not joining, pods failing)
- Serverless failures (Lambda timeout, cold starts)
- Database connectivity (RDS unreachable)

---

## 🏗️ AWS Architecture Layers (Where Problems Happen)

```
┌─────────────────────────────────────────────────────────┐
│ Layer 5: Application (Lambda, ECS, EKS)                 │
│   Problem: Function timeout, pod crash, OOM              │
├─────────────────────────────────────────────────────────┤
│ Layer 4: Security (IAM, Security Groups, NACLs)         │
│   Problem: AccessDenied, connection refused              │
├─────────────────────────────────────────────────────────┤
│ Layer 3: Networking (VPC, Subnets, Route Tables)        │
│   Problem: No internet, DNS failure, timeout             │
├─────────────────────────────────────────────────────────┤
│ Layer 2: Storage & Data (S3, RDS, DynamoDB)             │
│   Problem: Access denied, wrong endpoint                 │
├─────────────────────────────────────────────────────────┤
│ Layer 1: Infrastructure (EC2, ENI, EBS)                 │
│   Problem: Instance unreachable, disk full               │
└─────────────────────────────────────────────────────────┘
```

---

## 🔑 Key Concepts

### IAM (Identity & Access Management)
- **Principal** = WHO is making the request (user, role, service)
- **Action** = WHAT they want to do (s3:GetObject, ec2:RunInstances)
- **Resource** = WHICH resource (arn:aws:s3:::my-bucket/*)
- **Effect** = Allow or Deny

```json
{
  "Effect": "Allow",
  "Action": "s3:GetObject",
  "Resource": "arn:aws:s3:::my-bucket/*"
}
```

### VPC Networking
```
Internet
    │
Internet Gateway (IGW)
    │
Route Table (0.0.0.0/0 → IGW)
    │
Public Subnet ──── NAT Gateway
    │                    │
    │              Route Table (0.0.0.0/0 → NAT)
    │                    │
    │              Private Subnet
    │                    │
Security Group (inbound/outbound rules)
    │
EC2 Instance / Pod
```

### Common Error → Fix Mapping
| Error | Likely Cause | Fix |
|-------|-------------|-----|
| `AccessDenied` | Missing IAM permission | Add permission to policy |
| `Connection timed out` | SG blocking port | Add inbound rule |
| `Could not resolve host` | No DNS in VPC | Enable DNS hostnames |
| `Nodes NotReady` | aws-auth missing | Add node role to ConfigMap |
| `Request timeout` in Lambda | No NAT in VPC | Add NAT Gateway |

---

## 🚀 How To Use These Labs

### Prerequisites:
- AWS CLI configured (`aws configure`)
- AWS account with admin access (for fixing issues)
- Some labs can be simulated locally

### Steps:
1. `cd lab-01-iam-permission-denied && ./deploy.sh`
2. Read the AWS error output
3. Identify which AWS service/config is wrong
4. Fix using AWS CLI or Console
5. Verify the fix resolves the error

---

## 📋 Labs

| # | Lab | Difficulty | AWS Service | Error You'll See |
|---|-----|-----------|-------------|-----------------|
| 01 | IAM Permission Denied | ⭐ Easy | IAM | `AccessDenied` |
| 02 | S3 Bucket Policy | ⭐⭐ Medium | S3 + IAM | `Access Denied (403)` |
| 03 | VPC No Internet | ⭐⭐ Medium | VPC | `Connection timed out` |
| 04 | Security Group Rules | ⭐⭐ Medium | EC2/SG | `Connection refused` |
| 05 | EKS Node Not Joining | ⭐⭐⭐ Hard | EKS | `Nodes NotReady` |
| 06 | Lambda Timeout | ⭐⭐ Medium | Lambda | `Task timed out after 3s` |
| 07 | CloudFormation Rollback | ⭐⭐⭐ Hard | CFN | `ROLLBACK_COMPLETE` |
| 08 | ECR Push Denied | ⭐⭐ Medium | ECR | `denied: access forbidden` |
| 09 | RDS Connection Refused | ⭐⭐ Medium | RDS | `Connection refused` |
| 10 | Route53 DNS Broken | ⭐⭐ Medium | Route53 | `NXDOMAIN` |

---

## 🛠️ Essential AWS CLI Commands

```bash
# Identity
aws sts get-caller-identity       # Who am I?
aws iam list-attached-user-policies --user-name X  # My permissions

# Networking
aws ec2 describe-security-groups --group-ids sg-xxx
aws ec2 describe-route-tables --filters Name=vpc-id,Values=vpc-xxx
aws ec2 describe-nat-gateways

# EKS
aws eks describe-cluster --name my-cluster
aws eks update-kubeconfig --name my-cluster
kubectl get cm aws-auth -n kube-system -o yaml

# Debug
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRole
aws logs filter-log-events --log-group-name /aws/lambda/my-func
```

---

## 📖 Reference
- IAM: https://docs.aws.amazon.com/IAM/latest/UserGuide/
- VPC: https://docs.aws.amazon.com/vpc/latest/userguide/
- EKS: https://docs.aws.amazon.com/eks/latest/userguide/
- Troubleshooting: https://docs.aws.amazon.com/IAM/latest/UserGuide/troubleshoot.html
