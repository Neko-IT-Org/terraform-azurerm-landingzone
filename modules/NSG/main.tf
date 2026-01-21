###############################################################
# Captures the time when Terraform is first applied, used for tagging resources.
###############################################################
resource "time_static" "time" {}

###############################################################
# Creates an Azure Network Security Group (NSG) with configurable security rules and tagging.
###############################################################
resource "azurerm_network_security_group" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name


  # Defines one or more security rules for the NSG, based on the provided input variable.
  dynamic "security_rule" {
    for_each = var.security_rules
    content {
      name                         = security_rule.value.name
      priority                     = security_rule.value.priority
      direction                    = security_rule.value.direction
      access                       = security_rule.value.access
      protocol                     = security_rule.value.protocol
      source_port_range            = lookup(security_rule.value, "source_port_range", null)
      destination_port_range       = lookup(security_rule.value, "destination_port_range", null)
      source_address_prefix        = lookup(security_rule.value, "source_address_prefix", null)
      destination_address_prefix   = lookup(security_rule.value, "destination_address_prefix", null)
      source_port_ranges           = lookup(security_rule.value, "source_port_ranges", null)
      destination_port_ranges      = lookup(security_rule.value, "destination_port_ranges", null)
      source_address_prefixes      = lookup(security_rule.value, "source_address_prefixes", null)
      destination_address_prefixes = lookup(security_rule.value, "destination_address_prefixes", null)
      description                  = lookup(security_rule.value, "description", null)
    }
  }

  # Assigns tags to the NSG, including a 'CreatedOn' timestamp for resource tracking.
  tags = merge(
    var.tags,
    {
      CreatedOn = formatdate("DD-MM-YYYY hh:mm", timeadd(time_static.time.id, "1h"))
    }
  )
}
