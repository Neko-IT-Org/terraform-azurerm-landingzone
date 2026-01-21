# Name of the Azure Virtual Network (VNet) to be created.
variable "name" {
  description = "The name of the resource group"
  type        = string
}

# Azure region where the VNet will be deployed.
variable "location" {
  description = "The location of the resource group"
  type        = string
}

# Map of tags to assign to the VNet for resource organization and management.
variable "tags" {
  description = "A map of tags to assign to the resource group"
  type        = map(string)
}

# Name of the resource group in which the VNet will be created.
variable "resource_group_name" {
  description = "A map of tags to assign to the resource group"
  type        = string
}

# Flag to enable the association of a DDoS protection plan with the VNet.
variable "enable_ddos_protection" {
  description = "Whether to enable the DDoS protection plan on the virtual network"
  type        = bool
  default     = false
}

# The ID of the DDoS protection plan to associate with the VNet (optional).
variable "ddos_protection_plan_id" {
  description = "The ID of the DDoS protection plan to associate with the virtual network"
  type        = string
  default     = null
  nullable    = true
}

# List of CIDR blocks for the VNet address space (optional).
variable "address_space" {
  description = "The CIDR block for the virtual network"
  type        = list(string)
  default     = null
  nullable    = true
}

# List of DNS server IP addresses to be used by the VNet (optional).
variable "dns_servers" {
  description = "IP addresses of DNS servers to be used by the virtual network"
  type        = list(string)
  default     = null
  nullable    = true
}

# Optional single IPAM pool object to allocate addresses from at VNet level.
variable "ip_address_pool" {
  description = "Optional single IPAM pool to allocate addresses from at VNET level."
  # nullable single object; omit or set to null to skip the block
  type = object({
    id                     = string
    number_of_ip_addresses = string
  })
  default  = null
  nullable = true
}
