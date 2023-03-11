variable "mail_address" {
  description = "The email address to receive notifications"
  type        = string
}

variable "cloudflare_api_token" {
  description = "The Cloudflare API token"
  type        = string
}

variable "time_zone" {
  type        = string
  description = "The name of time zone as the basis for automatic update timing."
  default     = "UTC"
}

variable "dns_names" {
  type        = list(string)
  description = "The list of DNS names to be managed by acmebot."
}