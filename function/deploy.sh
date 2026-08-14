#!/bin/bash

# Deploy webhook demo

# 1. Get TF outputs
WEBHOOK_URL=$(cd ../terraform && terraform output -raw function_app_url)
echo "WEBHOOK_URL ${WEBHOOK_URL}"
FUNCTION_APP=$(cd ../terraform && terraform output -raw function_app_name)
echo "FUNCTION_APP ${FUNCTION_APP}"

# 2. Stage and deploy function code
mkdir -p function-app
cp function_app.py function-app/
cp host.json function-app/
cp requirements.txt function-app/

cd function-app && func azure functionapp publish $FUNCTION_APP --python && cd ..

# 4. Get webhook secret from Key Vault
# WEBHOOK_SECRET=$(az keyvault secret show \
#   --vault-name gh-webhook-secret \
#   --name github-webhook-secret \
#   --query value -o tsv)

# # 5. Configure webhook in GitHub (manual or via API)
# echo "GitHub Webhook URL: $WEBHOOK_URL"
# echo "GitHub Webhook Secret: $WEBHOOK_SECRET"
# echo ""
# echo "Add webhook in GitHub:"
# echo "  Settings → Webhooks → Add webhook"
# echo "  Payload URL: $WEBHOOK_URL"
# echo "  Secret: $WEBHOOK_SECRET"
# echo "  Content type: application/json"
# echo "  Events: Send me everything"
