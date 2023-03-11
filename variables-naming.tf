variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
}

variable "app_service_plan_name" {
  description = "The name of the app service plan"
  type        = string
}

variable "workspace_name" {
  description = "The name of the log analytics workspace"
  type        = string
}

variable "app_insights_name" {
  description = "The name of the application insights"
  type        = string
}

variable "function_app_name" {
  description = "The name of the function app"
  type        = string
}