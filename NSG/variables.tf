###############################################################
# Name of the Azure Network Security Group (NSG) to be created.
###############################################################
variable "name" {
  description = "The name of the NSG"
  type        = string
}

###############################################################
# Azure region where the NSG will be deployed.
###############################################################
variable "location" {
  description = "The location of the NSG"
  type        = string
}

###############################################################
# Name of the resource group in which the NSG will be created.
###############################################################
variable "resource_group_name" {
  description = "The name of the resource group where the NSG will be created"
  type        = string
}

###############################################################
# Map of tags to assign to the NSG for resource organization and management.
###############################################################
variable "tags" {
  description = "A map of tags to assign to the NSG"
  type        = map(string)
}

###############################################################
# List of security rule objects to be applied to the NSG. Each object defines rule properties and options.
###############################################################
variable "security_rules" {
  description = "List of security rules for the NSG"
  type = list(object({
    name      = string
    priority  = number
    direction = string
    access    = string
    protocol  = string

    source_port_range            = optional(string)
    destination_port_range       = optional(string)
    source_address_prefix        = optional(string)
    destination_address_prefix   = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_ranges      = optional(list(string))
    source_address_prefixes      = optional(list(string))
    destination_address_prefixes = optional(list(string))
    description                  = optional(string)
  }))
  default = []
}
