#!/bin/bash
set -e
echo "🚀 Lab 02: Cross-Account AssumeRole Failed"
echo "============================================"
echo ""
echo "⚠️  Creates: IAM Role with WRONG trust policy"
echo "   Cost: FREE"
read -p "Continue? (y/n): " confirm
[ "$confirm" != "y" ] && exit 0

ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
ROLE_NAME="lab02-cross-account-role"

# Create role with WRONG trust policy (trusts non-existent account)
cat > /tmp/lab02-trust.json << TRUST
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"AWS": "arn:aws:iam::999999999999:root"},
    "Action": "sts:AssumeRole",
    "Condition": {
      "StringEquals": {"sts:ExternalId": "wrong-external-id-12345"}
    }
  }]
}
TRUST

aws iam create-role --role-name $ROLE_NAME \
  --assume-role-policy-document file:///tmp/lab02-trust.json 2>/dev/null || true

aws iam attach-role-policy --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess 2>/dev/null || true

echo ""
echo "✅ Created role: $ROLE_NAME"
echo ""
echo "❌ TRY THIS (will FAIL):"
echo "   aws sts assume-role --role-arn arn:aws:iam::${ACCOUNT_ID}:role/$ROLE_NAME --role-session-name test"
echo ""
echo "   Error: 'is not authorized to perform: sts:AssumeRole'"
echo ""
echo "🔍 YOUR TASK: Fix the trust policy so YOUR account can assume the role"
echo "   1. The trust policy trusts account 999999999999 (doesn't exist!)"
echo "   2. Change it to trust YOUR account: $ACCOUNT_ID"
echo "   3. Remove or fix the ExternalId condition"
echo ""
echo "🛠️ Fix command:"
echo "   aws iam update-assume-role-policy --role-name $ROLE_NAME --policy-document file://fixed-trust.json"
echo ""
echo "🧹 When done: ./cleanup.sh"
