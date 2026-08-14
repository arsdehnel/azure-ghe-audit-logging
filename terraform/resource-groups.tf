# provisioned as part of the GHE org setup, one of these per org
resource "azurerm_resource_group" "gh_org_resources" {
  name     = "${var.per_gh_org_resource_prefix}-rg"
  location = "centralus"
}
# presumably owned by the security/siem team, one for all of GHE
resource "azurerm_resource_group" "sec_team_resources" {
  name     = "${var.sec_team_resource_prefix}-rg"
  location = "centralus"
}
