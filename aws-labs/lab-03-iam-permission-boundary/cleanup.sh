#!/bin/bash
USER="lab03-boundary-user"
for key in $(aws iam list-access-keys --user-name $USER --query 'AccessKeyMetadata[].AccessKeyId' --output text 2>/dev/null); do
  aws iam delete-access-key --user-name $USER --access-key-id $key; done
aws iam detach-user-policy --user-name $USER --policy-arn arn:aws:iam::aws:policy/AdministratorAccess 2>/dev/null
aws iam delete-user --user-name $USER 2>/dev/null
POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName=='lab03-boundary-policy'].Arn" --output text)
aws iam delete-policy --policy-arn $POLICY_ARN 2>/dev/null
echo "✅ Lab 03 cleaned up"
