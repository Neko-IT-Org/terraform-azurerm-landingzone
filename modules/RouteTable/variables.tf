###############################################################
# Name of the Azure Route Table to be created.
###############################################################
variable "name" {
  description = "The name of the resource group"
  type        = string
}

###############################################################
# Azure region where the route table will be deployed.
###############################################################
variable "location" {
  description = "The location of the resource group"
  type        = string
}

###############################################################
# Name of the resource group in which the route table will be created.
###############################################################
variable "resource_group_name" {
  description = "The name of the resource group where the resources will be created"
  type        = string

}

###############################################################
# Whether BGP route propagation is enabled for the route table.
###############################################################
variable "bgp_route_propagation_enabled" {
  description = "Whether BGP route propagation is enabled for the route table"
  type        = bool
  default     = true
}

###############################################################
# List of route objects to be added to the route table. Each object defines route properties and options.
###############################################################
variable "route" {
  description = "A list of routes to be added to the route table"
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  
  validation {
    condition = alltrue([
      for r in var.route : contains(
        ["VirtualNetworkGateway", "VnetLocal", "Internet", "VirtualAppliance", "None"],
        r.next_hop_type
      )
    ])
    error_message = "next_hop_type must be one of: VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance, or None."
  }

  validation {
    condition = alltrue([
      for r in var.route :
      r.next_hop_type != "VirtualAppliance" || r.next_hop_in_ip_address != null
    ])
    error_message = "next_hop_in_ip_address is required when next_hop_type is VirtualAppliance."
  }
}

###############################################################
# Map of tags to assign to the route table for resource organization and management.
###############################################################
variable "tags" {
  description = "A map of tags to assign to the resource group"
  type        = map(string)
  default     = {}
}
