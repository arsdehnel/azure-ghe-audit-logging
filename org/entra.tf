# # App registration — this is the identity GitHub Actions will authenticate as
resource "azuread_application" "github_oidc" {
  display_name = "ghe-org-${var.org_name}-actions-oidc"
}

resource "azuread_service_principal" "github_oidc" {
  client_id = azuread_application.github_oidc.client_id
}

# One federated credential per GitHub Organization at least for now.
# Subject claim format: org:<org>
# This must exactly match what GitHub puts in the OIDC token.
resource "azuread_application_federated_identity_credential" "github_org" {
  application_id = azuread_application.github_oidc.id
  display_name   = "ghe-org-${var.org_name}"
  description    = "GitHub Actions OIDC — ${var.org_name}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "org:${var.org_name}"
}
