data "azurerm_function_app_host_keys" "main" {
  name                = azurerm_windows_function_app.function.name
  resource_group_name = azurerm_resource_group.main.name
}

locals {
  http_body = jsonencode({
    "DnsNames" : var.dns_names,
  })
}

resource "null_resource" "acmebot_api" {
  provisioner "local-exec" {
    command = <<EOT
        curl -s -X POST ${azurerm_windows_function_app.function.default_hostname}/api/certificate \
             -H 'Content-Type: application/json' \
             -H ' X-Functions-Key : ${data.azurerm_function_app_host_keys.main.default_function_key}' \
             -d '${local.http_body}'
EOT
  }
}

