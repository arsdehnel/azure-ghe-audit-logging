resource "azurerm_resource_group" "sec_team_resources" {
  name     = "${var.sec_team_resource_prefix}-rg"
  location = "centralus"
}
