import os
import azure.functions as func
import json
import hmac
import hashlib
import logging
from datetime import datetime, timezone
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from azure.storage.blob import BlobClient

app = func.FunctionApp()

KEYVAULT_URL = os.environ["KEYVAULT_URL"]
STORAGE_ACCOUNT_URL = os.environ["STORAGE_ACCOUNT_URL"]
CONTAINER_NAME = "github-webhooks"

credential = DefaultAzureCredential()
kv_client = SecretClient(vault_url=KEYVAULT_URL, credential=credential)

_webhook_secret = None


def get_webhook_secret():
    global _webhook_secret
    if _webhook_secret is None:
        _webhook_secret = kv_client.get_secret("github-webhook-secret").value
    return _webhook_secret


@app.function_name("GitHubWebhook")
@app.route(route="webhook", methods=["POST"], auth_level=func.AuthLevel.ANONYMOUS)
def webhook_handler(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Webhook received")

    try:
        webhook_secret = get_webhook_secret()

        signature_header = req.headers.get("X-Hub-Signature-256", "")
        if not signature_header.startswith("sha256="):
            return func.HttpResponse("Invalid signature", status_code=401)

        body = req.get_body()
        expected_signature = "sha256=" + hmac.new(
            webhook_secret.encode(),
            body,
            hashlib.sha256
        ).hexdigest()

        if not hmac.compare_digest(signature_header, expected_signature):
            return func.HttpResponse("Signature validation failed", status_code=401)

        event = req.get_json()
        event_type = req.headers.get("X-GitHub-Event", "unknown")

        now = datetime.now(timezone.utc)
        blob_path = f"webhooks/{event_type}/{now.year:04d}/{now.month:02d}/{now.day:02d}/{now.isoformat()}.json"

        blob_client = BlobClient(
            account_url=STORAGE_ACCOUNT_URL,
            container_name=CONTAINER_NAME,
            blob_name=blob_path,
            credential=credential
        )

        blob_client.upload_blob(json.dumps(event), overwrite=False)
        logging.info(f"Event written to blob: {blob_path}")

        return func.HttpResponse(json.dumps({"status": "ok"}), status_code=202)

    except json.JSONDecodeError:
        return func.HttpResponse("Invalid JSON", status_code=400)
    except Exception as e:
        logging.error(f"Error: {str(e)}")
        return func.HttpResponse("Error", status_code=500)
