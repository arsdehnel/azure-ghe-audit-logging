
# # App registration — this is the identity GitHub Actions will authenticate as
resource "azuread_application" "github_oidc" {
  display_name = "ghe-org-${var.org_name}-actions-oidc"
}

resource "azuread_service_principal" "github_oidc" {
  client_id = azuread_application.github_oidc.client_id
}

resource "azurerm_role_assignment" "key_vault_reader" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Key Vault Reader"
  principal_id         = azuread_service_principal.github_oidc.object_id
}

# these are created via null resource while waiting for native Terraform provider support
# https://github.com/hashicorp/terraform-provider-azuread/issues/1807
resource "null_resource" "federated_credential_for_prs" {
  triggers = {
    org_name   = var.org_name
    org_id     = var.org_id
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<-EOT
      export GH_ORG_NAME="${var.org_name}"
      export GH_ORG_ID="${var.org_id}"
      export EXISTING_CRED_NAME="ghe-oidc-prs-${var.org_name}"

      EXISTING_CRED_ID=$(az rest --url "https://graph.microsoft.com/beta/applications/${azuread_application.github_oidc.object_id}/federatedIdentityCredentials" | jq -r --arg cred_name "$EXISTING_CRED_NAME" '.value[] | select( .name == $cred_name ) | .id')

      echo "EXISTING_CRED_NAME $EXISTING_CRED_NAME" >> debug.log
      echo "EXISTING_CRED_ID $EXISTING_CRED_ID" >> debug.log

      if [ -n "$EXISTING_CRED_ID" ]; then 
        echo "Credential already exists"
      else 
        envsubst < federated-cred-prs.json | az rest --method post \
          --url "https://graph.microsoft.com/beta/applications/${azuread_application.github_oidc.object_id}/federatedIdentityCredentials" \
          --headers "Content-Type=application/json" \
          --body @-
      fi
    EOT
  }
}
resource "null_resource" "federated_credential_for_branches" {
  triggers = {
    org_name   = var.org_name
    org_id     = var.org_id
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<-EOT
      export GH_ORG_NAME="${var.org_name}"
      export GH_ORG_ID="${var.org_id}"
      export EXISTING_CRED_NAME="ghe-oidc-branches-${var.org_name}"

      EXISTING_CRED_ID=$(az rest --url "https://graph.microsoft.com/beta/applications/${azuread_application.github_oidc.object_id}/federatedIdentityCredentials" | jq -r --arg cred_name "$EXISTING_CRED_NAME" '.value[] | select( .name == $cred_name ) | .id')

      echo "EXISTING_CRED_NAME $EXISTING_CRED_NAME" >> debug.log
      echo "EXISTING_CRED_ID $EXISTING_CRED_ID" >> debug.log

      if [ -n "$EXISTING_CRED_ID" ]; then 
        echo "Credential already exists"
      else 
        envsubst < federated-cred-branches.json | az rest --method post \
          --url "https://graph.microsoft.com/beta/applications/${azuread_application.github_oidc.object_id}/federatedIdentityCredentials" \
          --headers "Content-Type=application/json" \
          --body @-
      fi
    EOT
  }
}
