module "keyvault_acmebot" {
  source  = "shibayan/keyvault-acmebot/azurerm"
  version = "~> 2.0"

  function_app_name     = "oma-msdn-acmebot-func"
  app_service_plan_name = "oma-msdn-acmebot-asp"
  storage_account_name  = "omamsdnacmebotst"
  app_insights_name     = "oma-msdn-acmebot-api"
  workspace_name        = "oma-msdn-acmebot-log"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  mail_address          = var.mail_address
  vault_uri             = azurerm_key_vault.main.vault_uri

  azure_dns = {
    subscription_id = data.azurerm_client_config.current.subscription_id
  }
}