# variables.tf
data "azurerm_client_config" "current" {}

variable "name" {
  type        = string
  description = "Name of the Key Vault."
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tenant_id" {
  type    = string
  default = "090a1bf9-58cc-49fa-8a9e-3f7b0a100fa9"
}

variable "sku_name" {
  type    = string
  default = "premium"
}

variable "enable_rbac" {
  type    = bool
  default = true
}

variable "enabled_for_disk_encryption" {
  type    = bool
  default = false
}

variable "enabled_for_deployment" {
  type    = bool
  default = false
}

variable "enabled_for_template_deployment" {
  type    = bool
  default = false
}

variable "soft_delete_retention_days" {
  type    = number
  default = 90
}

variable "purge_protection_enabled" {
  type    = bool
  default = true
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "network_acls" {
  description = "Optional network ACLs config"
  type = object({
    default_action = string
    bypass         = string
    ip_rules       = optional(list(string))
    subnet_ids     = optional(list(string))
  })
  default  = null
  nullable = true
}
variable "tags" {
  type    = map(string)
  default = {}
}

variable "subnet_id" {
  type = string
}

variable "private_ip_address" {
  type = string
  default = null
}

variable "private_dns_zone_group" {
  type = object({
    dns_name             = optional(string)
    private_dns_zone_ids = optional(list(string))
  })
  default = null
}

