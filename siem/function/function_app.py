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

STORAGE_ACCOUNT_URL = os.environ["STORAGE_ACCOUNT_URL"]
CONTAINER_NAME = "github-webhooks"

credential = DefaultAzureCredential()

@app.function_name("GitHubWebhook")
@app.route(route="webhook", methods=["POST"], auth_level=func.AuthLevel.ANONYMOUS)
def webhook_handler(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Webhook received")

    signature_header = req.headers.get("X-Hub-Signature-256", "")
    if not signature_header.startswith("sha256="):
        return func.HttpResponse("Invalid signature", status_code=401)

    body = req.get_body()

    # parse org from body to find the right KV, but don't trust it yet
    try:
        payload = json.loads(body)
    except json.JSONDecodeError:
        return func.HttpResponse("Invalid JSON", status_code=400)

    org_name = payload.get("organization", {}).get("login")
    if not org_name:
        return func.HttpResponse("Missing organization", status_code=400)

    kv_client = SecretClient(vault_url=f"https://kv-{org_name}.vault.azure.net/", credential=credential)
    try:
        webhook_secret = kv_client.get_secret("gh-to-azure-webhook-secret").value
    except Exception:
        return func.HttpResponse("Unauthorized", status_code=401)

    expected = "sha256=" + hmac.new(webhook_secret.encode(), body, hashlib.sha256).hexdigest()
    if not hmac.compare_digest(signature_header, expected):
        return func.HttpResponse("Signature mismatch", status_code=401)

    try:
        event_type = req.headers.get("X-GitHub-Event", "unknown")
        delivery_id = req.headers.get("X-GitHub-Delivery", "unknown")

        now = datetime.now(timezone.utc)
        blob_path = f"webhooks/{event_type}/{now.year:04d}/{now.month:02d}/{now.day:02d}/{delivery_id}.json"

        envelope = {
            "delivery_id": delivery_id,
            "event_type": event_type,
            "received_at": now.isoformat(),
            "org": org_name,
            "payload": payload,
        }

        blob_client = BlobClient(
            account_url=STORAGE_ACCOUNT_URL,
            container_name=CONTAINER_NAME,
            blob_name=blob_path,
            credential=credential
        )

        blob_client.upload_blob(json.dumps(envelope), overwrite=True)
        logging.info(f"Event written to blob: {blob_path}")

        return func.HttpResponse(json.dumps({"status": "ok"}), status_code=202)

    except Exception as e:
        logging.error(f"Error: {str(e)}")
        return func.HttpResponse("Error", status_code=500)
