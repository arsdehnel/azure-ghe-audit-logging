output "vault_uri" {
  value = azurerm_key_vault.github_org_scoped_key_vault.vault_uri
}

output "entra_client_id" {
  value = azuread_application.github_oidc.client_id
}
