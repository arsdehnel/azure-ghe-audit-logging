resource "azurerm_resource_group" "org_resources" {
  name     = "${var.org_name}-rg"
  location = "centralus"
}
