resource "azurerm_storage_account" "storage" {
  name                            = var.storage_account_name
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  account_kind                    = "Storage"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  enable_https_traffic_only       = true
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"
}

resource "azurerm_service_plan" "serverfarm" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  os_type  = "Windows"
  sku_name = "Y1"
}

resource "azurerm_log_analytics_workspace" "workspace" {
  name                = var.workspace_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_application_insights" "insights" {
  name                = var.app_insights_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.workspace.id
}

resource "azurerm_windows_function_app" "function" {
  name                       = var.function_app_name
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  service_plan_id            = azurerm_service_plan.serverfarm.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key

  functions_extension_version = "~4"
  https_only                  = true

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"    = "https://stacmebotprod.blob.core.windows.net/keyvault-acmebot/v4/latest.zip"
    "WEBSITE_TIME_ZONE"           = var.time_zone
    "Acmebot:Cloudflare:ApiToken" = var.cloudflare_api_token
    "Acmebot:Contacts"            = var.mail_address
    "Acmebot:Endpoint"            = "https://acme-v02.api.letsencrypt.org/"
    "Acmebot:VaultBaseUrl"        = azurerm_key_vault.main.vault_uri
    "Acmebot:Environment"         = "AzureCloud"
    "Acmebot:MitigateChainOrder"  = true
  }


  identity {
    type = "SystemAssigned"
  }

  # dynamic "auth_settings" {
  #   for_each = toset(var.auth_settings != null ? [1] : [])
  #   content {
  #     enabled                       = var.auth_settings.enabled
  #     unauthenticated_client_action = var.auth_settings.unauthenticated_client_action
  #     issuer                        = var.auth_settings.issuer
  #     token_store_enabled           = var.auth_settings.token_store_enabled
  #     active_directory {
  #       allowed_audiences = var.auth_settings.active_directory.allowed_audiences
  #       client_id         = var.auth_settings.active_directory.client_id
  #     }
  #   }
  # }

  site_config {
    application_insights_connection_string = azurerm_application_insights.insights.connection_string
    ftps_state                             = "Disabled"
    minimum_tls_version                    = "1.2"

    application_stack {
      dotnet_version = "v6.0"
    }

    #   dynamic "ip_restriction" {
    #     for_each = var.allowed_ip_addresses
    #     content {
    #       ip_address = ip_restriction.value
    #     }
    #   }

  }

  lifecycle {
    ignore_changes = [
      app_settings["MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"],
      sticky_settings["app_setting_names"]
    ]
  }
}
