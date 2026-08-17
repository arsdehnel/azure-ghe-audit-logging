
resource "azurerm_storage_account" "sec_team_function" {
  name                     = substr(replace("${var.sec_team_resource_prefix}-function", "-", ""), 0, 24)
  resource_group_name      = azurerm_resource_group.sec_team_resources.name
  location                 = azurerm_resource_group.sec_team_resources.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
