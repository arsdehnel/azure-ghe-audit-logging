# resource "azurerm_eventgrid_event_subscription" "webhook_to_log_analytics" {
#   name                  = "github-webhooks-to-sentinel"
#   scope                 = data.azurerm_storage_account.webhook_events.id
#   event_delivery_schema = "EventGridSchema"

#   # Filter: only trigger on blob creation in github-webhooks container
#   storage_blob_dead_letter_destination {
#     storage_account_id          = data.azurerm_storage_account.webhook_events.id
#     storage_blob_container_name = "event-grid-deadletter" # Optional: for tracking failures
#   }

#   storage_queue_endpoint {
#     storage_account_id = data.azurerm_storage_account.webhook_events.id
#     queue_name         = "webhook-events-queue" # Queues for intermediate buffering (optional)
#   }

#   included_event_types = [
#     "Microsoft.Storage.BlobCreated"
#   ]

#   subject_filter {
#     subject_begins_with = "/blobServices/default/containers/${azurerm_storage_container.webhooks.name}"
#     subject_ends_with   = ".json"
#   }

#   depends_on = [
#     azurerm_storage_account.webhook_events
#   ]

# }
