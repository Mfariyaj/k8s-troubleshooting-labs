#!/bin/bash
set -e
echo "🚀 Lab 01: IAM Permission Denied"
echo "=================================="
echo ""
echo "⚠️  This will create real AWS resources in your account!"
echo "   Cost: FREE (IAM has no charges)"
echo ""
read -p "Continue? (y/n): " confirm
[ "$confirm" != "y" ] && exit 0

LAB_USER="lab01-restricted-user"

echo ""
echo "📦 Creating restricted IAM user..."

# Create user
aws iam create-user --user-name $LAB_USER 2>/dev/null || echo "   User already exists"

# Attach ONLY S3 read policy (no EC2, no Lambda, no anything else)
aws iam attach-user-policy \
  --user-name $LAB_USER \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# Create access keys
KEYS=$(aws iam create-access-key --user-name $LAB_USER 2>/dev/null)
if [ $? -eq 0 ]; then
  ACCESS_KEY=$(echo $KEYS | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['AccessKey']['AccessKeyId'])")
  SECRET_KEY=$(echo $KEYS | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['AccessKey']['SecretAccessKey'])")
  
  echo ""
  echo "✅ Setup complete!"
  echo ""
  echo "🔑 Credentials for restricted user:"
  echo "   Access Key: $ACCESS_KEY"
  echo "   Secret Key: $SECRET_KEY"
  echo ""
  echo "Configure a profile:"
  echo "   aws configure --profile restricted"
  echo "   (paste the keys above)"
  echo ""
  echo "❌ NOW TRY THESE (should FAIL with AccessDenied):"
  echo "   aws ec2 describe-instances --profile restricted"
  echo "   aws lambda list-functions --profile restricted"
  echo "   aws iam list-users --profile restricted"
  echo ""
  echo "✅ THIS SHOULD WORK:"
  echo "   aws s3 ls --profile restricted"
  echo ""
  echo "🔍 YOUR TASK: Fix the permissions so EC2 commands work!"
  echo "   Hint: Add EC2 read permissions to the user"
  echo ""
  echo "🧹 When done: ./cleanup.sh"
else
  echo "   Access keys already exist. Delete old ones first or use existing."
  echo "   aws iam list-access-keys --user-name $LAB_USER"
fi
