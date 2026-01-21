# Captures the time when Terraform is first applied, used for tagging resources.
resource "time_static" "time" {}

# Creates an Azure Virtual Network (VNet) with optional DDOS protection and IP address pool configuration.
resource "azurerm_virtual_network" "this" {
  # Name of the virtual network, provided via variable.
  name = var.name

  # Address space for the VNet. If not provided, set to null.
  address_space = var.address_space != [] ? var.address_space : null

  # Azure region for the VNet.
  location = var.location

  # Resource group in which to create the VNet.
  resource_group_name = var.resource_group_name

  # Optional DNS servers for the VNet. If not provided, set to null.
  dns_servers = var.dns_servers != [] ? var.dns_servers : null


  # Optionally enable a DDoS protection plan when requested and an ID is provided.
  dynamic "ddos_protection_plan" {
    for_each = var.enable_ddos_protection && var.ddos_protection_plan_id != null ? [var.ddos_protection_plan_id] : []
    content {
      enable = var.enable_ddos_protection
      id     = ddos_protection_plan.value
    }
  }

  # Optionally configure an IP address pool if provided.
  dynamic "ip_address_pool" {
    for_each = var.ip_address_pool == null ? [] : [var.ip_address_pool]
    content {
      id                     = ip_address_pool.value.id
      number_of_ip_addresses = ip_address_pool.value.number_of_ip_addresses
    }
  }

  # Merge user-provided tags with a 'CreatedOn' timestamp.
  tags = merge(
    var.tags,
    {
      # 'CreatedOn' tag uses the static time, formatted as DD-MM-YYYY hh:mm and adds 1 hour.
      CreatedOn = formatdate("DD-MM-YYYY hh:mm", timeadd(time_static.time.id, "1h"))
    }
  )
}
