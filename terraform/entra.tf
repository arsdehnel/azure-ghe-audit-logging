# # App registration — this is the identity GitHub Actions will authenticate as
# resource "azuread_application" "github_oidc" {
#   display_name = "${var.webhook_resource_prefix}-github-oidc"
# }

# resource "azuread_service_principal" "github_oidc" {
#   client_id = azuread_application.github_oidc.client_id
# }

# # One federated credential per GitHub Environment.
# # Subject claim format: repo:<org>/<repo>:environment:<env>
# # This must exactly match what GitHub puts in the OIDC token.
# resource "azuread_application_federated_identity_credential" "github_env" {
#   application_id = azuread_application.github_oidc.id
#   display_name   = "github-org-${var.github_org}"
#   description    = "GitHub Actions OIDC — ${var.github_org}"
#   audiences      = ["api://AzureADTokenExchange"]
#   issuer         = "https://token.actions.githubusercontent.com"
#   subject        = "org:${var.github_org}"
# }
