resource "azurerm_key_vault" "github_org_scoped_key_vault" {
  name                        = "ghe-org-kv-${var.org_name}"
  location                    = azurerm_resource_group.org_resources.location
  resource_group_name         = azurerm_resource_group.org_resources.name
  rbac_authorization_enabled  = true
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
}

resource "azurerm_role_assignment" "terraform_kv_secrets_officer" {
  scope                = azurerm_key_vault.github_org_scoped_key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "gh_webhook_secret" {
  name         = "gh-to-azure-webhook-secret"
  value        = var.webhook_secret
  key_vault_id = azurerm_key_vault.github_org_scoped_key_vault.id
  # explicit depends on because without this Terraform doesn't wait for the role
  # which gives our Terraform commands permissions to create this secret
  depends_on = [azurerm_role_assignment.terraform_kv_secrets_officer]
}
