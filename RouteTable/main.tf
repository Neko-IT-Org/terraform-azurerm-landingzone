###############################################################
# Captures the time when Terraform is first applied, used for tagging resources.
###############################################################
resource "time_static" "time" {}

###############################################################
# Creates an Azure Route Table with configurable routes and tagging.
###############################################################
resource "azurerm_route_table" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Defines one or more routes for the route table, based on the provided input variable.
  dynamic "route" {
    for_each = var.route
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = lookup(route.value, "next_hop_in_ip_address", null)
    }
  }

  # Assigns tags to the route table, including a 'CreatedOn' timestamp for resource tracking.
  tags = merge(
    var.tags,
    {
      CreatedOn = formatdate("DD-MM-YYYY hh:mm", timeadd(time_static.time.id, "1h"))
    }
  )
}
