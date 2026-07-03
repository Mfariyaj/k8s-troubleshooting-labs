#!/bin/bash
set -e
echo "🚀 Lab 03: Permission Boundary Blocking"
echo "========================================="
echo "   Cost: FREE"
read -p "Continue? (y/n): " confirm
[ "$confirm" != "y" ] && exit 0

USER_NAME="lab03-boundary-user"

# Create permission boundary (only allows S3 and CloudWatch)
cat > /tmp/lab03-boundary.json << 'POLICY'
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["s3:*", "cloudwatch:*", "logs:*"],
    "Resource": "*"
  }]
}
POLICY

BOUNDARY_ARN=$(aws iam create-policy --policy-name lab03-boundary-policy \
  --policy-document file:///tmp/lab03-boundary.json \
  --query 'Policy.Arn' --output text 2>/dev/null || \
  aws iam list-policies --query "Policies[?PolicyName=='lab03-boundary-policy'].Arn" --output text)

# Create user WITH boundary, but give them AdministratorAccess
aws iam create-user --user-name $USER_NAME --permissions-boundary $BOUNDARY_ARN 2>/dev/null || true
aws iam attach-user-policy --user-name $USER_NAME \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

KEYS=$(aws iam create-access-key --user-name $USER_NAME 2>/dev/null)
if [ $? -eq 0 ]; then
  AK=$(echo $KEYS | python3 -c "import sys,json; print(json.load(sys.stdin)['AccessKey']['AccessKeyId'])")
  SK=$(echo $KEYS | python3 -c "import sys,json; print(json.load(sys.stdin)['AccessKey']['SecretAccessKey'])")
  echo ""
  echo "✅ Created user with AdministratorAccess BUT permission boundary!"
  echo "   Access Key: $AK"
  echo "   Secret Key: $SK"
  echo ""
  echo "❌ PARADOX: User has AdministratorAccess but CAN'T do EC2/IAM/Lambda!"
  echo "   aws ec2 describe-instances --profile lab03  → AccessDenied!"
  echo "   aws s3 ls --profile lab03                   → Works!"
  echo ""
  echo "🔍 YOUR TASK: Understand why Admin access is blocked, fix boundary"
fi
echo "🧹 When done: ./cleanup.sh"
