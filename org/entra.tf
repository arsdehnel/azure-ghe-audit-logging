# # App registration — this is the identity GitHub Actions will authenticate as
resource "azuread_application" "github_oidc" {
  display_name = "ghe-org-${var.org_name}-actions-oidc"
}

resource "azuread_service_principal" "github_oidc" {
  client_id = azuread_application.github_oidc.client_id
}

# One federated credential per GitHub Organization.
# Subject is the bare org slug, matching GitHub's custom subject claim template
# configured via: gh api --method PUT /orgs/<org>/actions/oidc/customization/sub
#                          --field "include_claim_keys[]=repository_owner"
resource "azuread_application_federated_identity_credential" "github_org" {
  application_id = azuread_application.github_oidc.id
  display_name   = "ghe-org-${var.org_name}"
  description    = "GitHub Actions OIDC — ${var.org_name}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = var.org_name
}
