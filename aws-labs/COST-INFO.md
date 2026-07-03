# 💰 AWS Labs - Cost & Billing Information

## ⚠️ IMPORTANT: Read Before Running Any Lab!

These labs create REAL AWS resources that may incur charges. Always run `cleanup.sh` when done!

---

## 🟢 FREE Labs (No AWS charges)

| Lab | Resources Created | Cost | Notes |
|-----|------------------|------|-------|
| 01 | IAM User + Policy | **$0.00** | IAM is always free |
| 02 | IAM Role + Trust Policy | **$0.00** | IAM is always free |
| 03 | IAM User + Permission Boundary | **$0.00** | IAM is always free |
| 04 | IAM Service-Linked Role | **$0.00** | IAM is always free |
| 05 | IAM Session Policy | **$0.00** | IAM is always free |
| 06 | IAM Condition Keys | **$0.00** | IAM is always free |
| 07 | Secrets Manager Secret | **$0.40/month** | First 30 days free trial |
| 08 | KMS Key | **$1.00/month** | First key may be free |
| 45 | Organization SCP | **$0.00** | SCPs are free |
| 47 | CloudTrail Config | **$0.00** | Config changes are free |
| 48 | Service Quotas Check | **$0.00** | Read-only operations |

---

## 🟡 LOW COST Labs ($0.01 - $0.10/hour)

| Lab | Resources Created | Cost/Hour | Cost if Left 1 Day | Cleanup Urgency |
|-----|------------------|-----------|--------------------:|----------------|
| 09 | VPC + Subnets + Route Tables | **$0.00** | $0.00 | Low (VPC is free) |
| 10 | VPC Peering Connection | **$0.01** | $0.24 | Low |
| 11 | Transit Gateway | **$0.05** | $1.20 | ⚠️ Medium |
| 12 | Security Group (testing) | **$0.00** | $0.00 | Low |
| 13 | NACLs (testing) | **$0.00** | $0.00 | Low |
| 14 | VPC Endpoint (Gateway) | **$0.00** | $0.00 | Low (Gateway endpoints free) |
| 14 | VPC Endpoint (Interface) | **$0.01** | $0.24 | Low |
| 15 | Private Hosted Zone | **$0.50/month** | $0.02 | Low |
| 23 | ECR Repository | **$0.00** | $0.00 | Low (empty repo free) |
| 28 | API Gateway (REST) | **$0.00** | $0.00 | Free tier: 1M calls/month |
| 31 | S3 Bucket | **$0.00** | $0.00 | Free tier: 5GB |
| 32 | S3 Replication Rule | **$0.00** | $0.00 | Config is free |
| 42 | S3 Lifecycle Policy | **$0.00** | $0.00 | Policy is free |

---

## 🟠 MEDIUM COST Labs ($0.10 - $1.00/hour)

| Lab | Resources Created | Cost/Hour | Cost if Left 1 Day | Cleanup Urgency |
|-----|------------------|-----------|--------------------:|----------------|
| 16 | ALB + EC2 t2.micro | **$0.03** | $0.72 | ⚠️ Cleanup same day |
| 17 | EKS Cluster + Nodes | **$0.10** | $2.40 | ⚠️ Cleanup ASAP |
| 18 | EKS + IRSA Config | **$0.10** | $2.40 | ⚠️ Cleanup ASAP |
| 19 | EKS + ALB Controller | **$0.13** | $3.12 | ⚠️ Cleanup ASAP |
| 20 | EKS + Autoscaler | **$0.10** | $2.40 | ⚠️ Cleanup ASAP |
| 21 | EKS + EBS PV | **$0.11** | $2.64 | ⚠️ Cleanup ASAP |
| 22 | EKS + CoreDNS | **$0.10** | $2.40 | ⚠️ Cleanup ASAP |
| 24 | ECS Fargate Task | **$0.04** | $0.96 | ⚠️ Medium |
| 25 | Lambda + VPC ENI | **$0.00** | $0.00 | Low (pay per invoke) |
| 26 | Lambda Function | **$0.00** | $0.00 | Low (pay per invoke) |
| 27 | Lambda + VPC | **$0.00** | $0.00 | Low |
| 29 | API GW + Authorizer | **$0.00** | $0.00 | Low |
| 30 | Step Functions | **$0.00** | $0.00 | Free tier: 4000/month |
| 39 | Unused EBS Volumes | **$0.10** | $2.40 | ⚠️ These ARE the cost! |
| 40 | Over-sized EC2 | **$0.17** | $4.08 | 🔴 Cleanup ASAP |
| 43 | NAT Gateway | **$0.045** | $1.08 | ⚠️ Medium |
| 44 | Cross-AZ Data Transfer | **$0.01/GB** | Varies | Medium |
| 46 | Cross-Account Role | **$0.00** | $0.00 | Low |
| 51 | Cloud Map Namespace | **$0.10** | $2.40 | ⚠️ Medium |
| 55 | CodeDeploy + EC2 | **$0.03** | $0.72 | ⚠️ Medium |

---

## 🔴 HIGHER COST Labs ($1.00+/hour)

| Lab | Resources Created | Cost/Hour | Cost if Left 1 Day | Cleanup Urgency |
|-----|------------------|-----------|--------------------:|----------------|
| 33 | RDS db.t3.micro | **$0.017** | $0.41 | ⚠️ Medium |
| 34 | RDS Multi-AZ | **$0.034** | $0.82 | ⚠️ Medium |
| 35 | DynamoDB (provisioned) | **$0.01** | $0.24 | Low |
| 36 | ElastiCache t3.micro | **$0.017** | $0.41 | ⚠️ Medium |
| 37 | RDS with storage | **$0.017** | $0.41 | ⚠️ Medium |
| 38 | Aurora Global | **$0.10+** | $2.40+ | 🔴 Cleanup IMMEDIATELY |
| 49 | DMS Replication | **$0.04** | $0.96 | ⚠️ Medium |
| 52 | App Mesh | **$0.00** | $0.00 | Low (config only) |
| 54 | ALB + EC2 + RDS | **$0.07** | $1.68 | 🔴 Cleanup same day |

---

## 📊 Total Cost Estimate (if you do ALL labs in one day)

| Scenario | Estimated Cost |
|----------|---------------|
| Only FREE labs (01-08, 45, 47, 48) | **$0.00** |
| FREE + LOW cost labs | **< $2.00** |
| ALL labs (complete in 2 hours each) | **$5 - $15** |
| ALL labs (forget to cleanup for 1 day) | **$20 - $50** ⚠️ |
| ALL labs (forget for 1 week) | **$100 - $300** 🔴 |

---

## ✅ How to Minimize Costs

1. **Always run `./cleanup.sh` immediately after each lab**
2. **Start with FREE labs (01-08)** — practice IAM for free!
3. **Do paid labs one at a time** — deploy, practice (max 1 hour), cleanup
4. **Set a billing alarm:**
   ```bash
   aws cloudwatch put-metric-alarm \
     --alarm-name "BillingAlarm-10USD" \
     --metric-name EstimatedCharges \
     --namespace AWS/Billing \
     --statistic Maximum \
     --period 21600 \
     --threshold 10 \
     --comparison-operator GreaterThanThreshold \
     --dimensions Name=Currency,Value=USD \
     --evaluation-periods 1 \
     --alarm-actions <your-sns-topic-arn>
   ```
5. **Check your bill:** https://console.aws.amazon.com/billing/

---

## 🧹 Emergency Cleanup (Delete ALL lab resources)

```bash
# Run cleanup for all labs at once:
for lab in lab-*/; do
  echo "Cleaning: $lab"
  cd "$lab" && ./cleanup.sh 2>/dev/null && cd ..
done

# Check for any remaining resources:
aws ec2 describe-instances --filters Name=tag-key,Values=Lab --query 'Reservations[].Instances[].InstanceId'
aws iam list-users --query 'Users[?starts_with(UserName,`lab`)].UserName'
aws ec2 describe-vpcs --filters Name=tag-key,Values=Lab --query 'Vpcs[].VpcId'
```

---

## 💡 AWS Free Tier Reminder

If your account is < 12 months old, you get:
- EC2: 750 hours/month of t2.micro
- S3: 5GB storage
- RDS: 750 hours/month of db.t2.micro
- Lambda: 1M requests/month
- DynamoDB: 25GB + 25 read/write units
- CloudWatch: 10 alarms free

Most labs fit within free tier if done quickly!
