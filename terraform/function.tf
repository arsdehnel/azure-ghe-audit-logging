# ============================================================================
# App Service Plan
# ============================================================================

resource "azurerm_service_plan" "webhook_function" {
  name                = "${var.sec_team_resource_prefix}-webhook-asp"
  location            = azurerm_resource_group.sec_team_resources.location
  resource_group_name = azurerm_resource_group.sec_team_resources.name
  os_type             = "Linux"
  sku_name            = "Y1" # Consumption tier (cheap, serverless)

  tags = {
    component = "github-webhooks"
    purpose   = "function-hosting"
  }
}

# ============================================================================
# Azure Function App
# ============================================================================

resource "azurerm_linux_function_app" "webhook_handler" {
  name                       = "${var.sec_team_resource_prefix}-${data.azurerm_client_config.current.subscription_id}"
  location                   = azurerm_resource_group.sec_team_resources.location
  resource_group_name        = azurerm_resource_group.sec_team_resources.name
  service_plan_id            = azurerm_service_plan.webhook_function.id
  storage_account_name       = azurerm_storage_account.sec_team_function.name
  storage_account_access_key = azurerm_storage_account.sec_team_function.primary_access_key

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"              = "python"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.webhook_function.connection_string
    "KEYVAULT_URL"                          = azurerm_key_vault.gh_webhook_secret.vault_uri
    "STORAGE_ACCOUNT_URL"                   = azurerm_storage_account.sec_team_logs.primary_blob_endpoint
  }

  site_config {
    application_stack {
      python_version = "3.12"
    }
  }

  https_only = true

  tags = {
    component = "github-webhooks"
    purpose   = "webhook-ingestion"
  }
}

# ============================================================================
# Application Insights (Optional but Recommended)
# ============================================================================

resource "azurerm_application_insights" "webhook_function" {
  name                = "webhook-function-insights"
  location            = azurerm_resource_group.sec_team_resources.location
  resource_group_name = azurerm_resource_group.sec_team_resources.name
  application_type    = "web"

  tags = {
    component = "github-webhooks"
    purpose   = "function-monitoring"
  }
}

# ============================================================================
# Role Assignments
# ============================================================================

# Allow Function to read webhook secret from Key Vault
resource "azurerm_role_assignment" "function_kv_secret_read" {
  scope                = azurerm_key_vault.gh_webhook_secret.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_function_app.webhook_handler.identity[0].principal_id
}

# Allow Function to write blobs to webhook storage account
resource "azurerm_role_assignment" "function_blob_write" {
  scope                = azurerm_storage_account.sec_team_logs.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_function_app.webhook_handler.identity[0].principal_id
}
