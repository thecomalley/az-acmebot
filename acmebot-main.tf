resource "azurerm_resource_group" "main" {
  name     = "acmebot-msdn-rg"
  location = "Australia East"
}

data "azurerm_client_config" "current" {}