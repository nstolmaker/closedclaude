#!/usr/bin/env bash
set -euo pipefail

ACCOUNT_ID="890084819993"
HOSTED_ZONE_ID="Z01237231H0TYJ8VRF1GJ"
USER_NAME="sillystring-ddns"
POLICY_NAME="sillystring-ddns-route53"

echo "==> Creating IAM user: $USER_NAME"
aws iam create-user --user-name "$USER_NAME"

echo "==> Creating inline policy: $POLICY_NAME"
aws iam put-user-policy \
  --user-name "$USER_NAME" \
  --policy-name "$POLICY_NAME" \
  --policy-document "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [
      {
        \"Effect\": \"Allow\",
        \"Action\": [
          \"route53:ChangeResourceRecordSets\",
          \"route53:ListResourceRecordSets\"
        ],
        \"Resource\": \"arn:aws:route53:::hostedzone/$HOSTED_ZONE_ID\"
      }
    ]
  }"

echo "==> Creating access key"
CREDS=$(aws iam create-access-key --user-name "$USER_NAME")

KEY_ID=$(echo "$CREDS" | python3 -c "import sys,json; d=json.load(sys.stdin)['AccessKey']; print(d['AccessKeyId'])")
SECRET=$(echo "$CREDS" | python3 -c "import sys,json; d=json.load(sys.stdin)['AccessKey']; print(d['SecretAccessKey'])")

echo ""
echo "=== Done. Credentials for $USER_NAME ==="
echo "AWS_ACCESS_KEY_ID:     $KEY_ID"
echo "AWS_SECRET_ACCESS_KEY: $SECRET"
echo ""
echo "Run this to configure the default profile on sillystring:"
echo "  aws configure"
echo "  # Access Key ID:     $KEY_ID"
echo "  # Secret Access Key: $SECRET"
echo "  # Region:            us-east-1"
echo "  # Output format:     json"
echo ""
echo "Or write it directly (non-interactively):"
echo "  aws configure set aws_access_key_id $KEY_ID"
echo "  aws configure set aws_secret_access_key $SECRET"
echo "  aws configure set region us-east-1"
echo "  aws configure set output json"
