resource "azurerm_key_vault" "gh_webhook_secret" {
  name                        = "gh-webhook-secret"
  location                    = azurerm_resource_group.gh_org_resources.location
  resource_group_name         = azurerm_resource_group.gh_org_resources.name
  rbac_authorization_enabled  = true
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

}

resource "azurerm_role_assignment" "terraform_kv_secrets_officer" {
  scope                = azurerm_key_vault.gh_webhook_secret.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "gh_webhook_secret" {
  name         = "github-webhook-secret"
  value        = var.webhook_secret
  key_vault_id = azurerm_key_vault.gh_webhook_secret.id
}
