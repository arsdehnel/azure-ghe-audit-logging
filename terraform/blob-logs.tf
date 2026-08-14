resource "azurerm_storage_account" "sec_team_logs" {
  name                     = substr(replace("${var.sec_team_resource_prefix}-logs", "-", ""), 0, 24)
  resource_group_name      = azurerm_resource_group.sec_team_resources.name
  location                 = azurerm_resource_group.sec_team_resources.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"
}

resource "azurerm_storage_container" "audit_logs" {
  storage_account_id = azurerm_storage_account.sec_team_logs.id
  name               = "audit-logs"
}

resource "azurerm_storage_container" "webhooks" {
  storage_account_id = azurerm_storage_account.sec_team_logs.id
  name               = "github-webhooks"
}
