#!/bin/bash

# Deploy webhook demo

# 1. Get TF outputs
WEBHOOK_URL=$(cd ../terraform && terraform output -raw function_app_url)
echo "WEBHOOK_URL ${WEBHOOK_URL}"
FUNCTION_APP=$(cd ../terraform && terraform output -raw function_app_name)
echo "FUNCTION_APP ${FUNCTION_APP}"

GH_ORG="salesforce-cicd-demo"

# 2. Stage and deploy function code
mkdir -p function-app
cp function_app.py function-app/
cp host.json function-app/
cp requirements.txt function-app/

cd function-app && func azure functionapp publish $FUNCTION_APP --python && cd ..

# 4. Get webhook secret from Key Vault
WEBHOOK_SECRET=$(az keyvault secret show \
  --vault-name gh-webhook-secret \
  --name github-webhook-secret \
  --query value -o tsv)

# 5. Create or update org webhook in GitHub
EXISTING_HOOK_ID=$(gh api /orgs/$GH_ORG/hooks \
  --jq ".[] | select(.config.url == \"$WEBHOOK_URL\") | .id" 2>/dev/null)

if [ -n "$EXISTING_HOOK_ID" ]; then
  echo "Updating existing webhook ${EXISTING_HOOK_ID}"
  gh api --method PATCH /orgs/$GH_ORG/hooks/$EXISTING_HOOK_ID \
    --field active=true \
    --field "config[url]=$WEBHOOK_URL" \
    --field "config[content_type]=json" \
    --field "config[secret]=$WEBHOOK_SECRET" \
    --field "config[insecure_ssl]=0"
else
  echo "Creating new webhook"
  gh api --method POST /orgs/$GH_ORG/hooks \
    --field name=web \
    --field active=true \
    --field "events[]=*" \
    --field "config[url]=$WEBHOOK_URL" \
    --field "config[content_type]=json" \
    --field "config[secret]=$WEBHOOK_SECRET" \
    --field "config[insecure_ssl]=0"
fi
