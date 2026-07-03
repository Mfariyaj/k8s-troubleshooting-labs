#!/bin/bash
echo "╔══════════════════════════════════════════════════════╗"
echo "║  AWS Labs - Prerequisites Setup                      ║"
echo "║  Run this ONCE before starting any AWS lab           ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# Check AWS CLI
if ! command -v aws &>/dev/null; then
  echo "❌ AWS CLI not installed!"
  echo "   Install: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
  exit 1
fi
echo "✅ AWS CLI: $(aws --version | head -c 30)"

# Check credentials
if ! aws sts get-caller-identity &>/dev/null; then
  echo "❌ AWS credentials not configured!"
  echo ""
  echo "   Option 1: aws configure"
  echo "   Option 2: Export keys:"
  echo "     export AWS_ACCESS_KEY_ID=your-key"
  echo "     export AWS_SECRET_ACCESS_KEY=your-secret"
  echo "     export AWS_DEFAULT_REGION=us-east-1"
  exit 1
fi

ACCOUNT=$(aws sts get-caller-identity --query 'Account' --output text)
USER_ARN=$(aws sts get-caller-identity --query 'Arn' --output text)
REGION=${AWS_DEFAULT_REGION:-$(aws configure get region 2>/dev/null || echo "us-east-1")}

echo "✅ Authenticated!"
echo "   Account: $ACCOUNT"
echo "   Identity: $USER_ARN"
echo "   Region: $REGION"
echo ""

# Check permissions
echo "🔍 Checking permissions..."
PERMS_OK=true

aws iam list-users --max-items 1 &>/dev/null || { echo "   ⚠️ Missing: IAM permissions"; PERMS_OK=false; }
aws ec2 describe-vpcs --max-results 1 &>/dev/null || { echo "   ⚠️ Missing: EC2/VPC permissions"; PERMS_OK=false; }
aws s3 ls --max-items 1 &>/dev/null 2>&1 || { echo "   ⚠️ Missing: S3 permissions"; PERMS_OK=false; }

if [ "$PERMS_OK" = true ]; then
  echo "✅ Sufficient permissions for labs"
else
  echo ""
  echo "⚠️  Some permissions missing. You need admin or PowerUser access."
  echo "   Recommended: Attach 'AdministratorAccess' policy to your user/role"
fi

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║  ✅ Prerequisites check complete!                    ║"
echo "║                                                      ║"
echo "║  You can now run any lab:                            ║"
echo "║    cd lab-01-iam-permission-denied                   ║"
echo "║    ./deploy.sh                                       ║"
echo "║                                                      ║"
echo "║  ⚠️  IMPORTANT:                                      ║"
echo "║  - Always run ./cleanup.sh after each lab            ║"
echo "║  - Some labs cost money (NAT Gateway, ALB, EC2)      ║"
echo "║  - Free labs: 01-08 (IAM only)                       ║"
echo "║  - Paid labs: 09-55 (VPC, EC2, ALB, RDS, Lambda)     ║"
echo "╚══════════════════════════════════════════════════════╝"
