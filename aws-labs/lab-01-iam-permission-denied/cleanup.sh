#!/bin/bash
LAB_USER="lab01-restricted-user"
echo "🧹 Cleaning up Lab 01..."

# Delete access keys
for key in $(aws iam list-access-keys --user-name $LAB_USER --query 'AccessKeyMetadata[].AccessKeyId' --output text 2>/dev/null); do
  aws iam delete-access-key --user-name $LAB_USER --access-key-id $key
done

# Detach all policies
for policy in $(aws iam list-attached-user-policies --user-name $LAB_USER --query 'AttachedPolicies[].PolicyArn' --output text 2>/dev/null); do
  aws iam detach-user-policy --user-name $LAB_USER --policy-arn $policy
done

# Delete inline policies
for policy in $(aws iam list-user-policies --user-name $LAB_USER --query 'PolicyNames[]' --output text 2>/dev/null); do
  aws iam delete-user-policy --user-name $LAB_USER --policy-name $policy
done

# Delete user
aws iam delete-user --user-name $LAB_USER 2>/dev/null
echo "✅ Cleaned up! User '$LAB_USER' deleted."
