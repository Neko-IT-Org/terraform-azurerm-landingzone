###############################################################
# Creates an Azure Key Vault with configurable access, network, and security settings.
###############################################################
resource "azurerm_key_vault" "this" {
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tenant_id                       = var.tenant_id
  sku_name                        = var.sku_name
  rbac_authorization_enabled      = var.enable_rbac
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_template_deployment = var.enabled_for_template_deployment
  soft_delete_retention_days      = var.soft_delete_retention_days
  purge_protection_enabled        = var.purge_protection_enabled
  public_network_access_enabled   = var.public_network_access_enabled

  # Optionally configure network ACLs if provided.
  dynamic "network_acls" {
    for_each = (
      var.network_acls != null ? [1] : []
    )
    content {
      default_action             = var.network_acls.default_action
      bypass                     = var.network_acls.bypass
      ip_rules                   = try(var.network_acls.ip_rules, [])
      virtual_network_subnet_ids = try(var.network_acls.subnet_ids, [])
    }
  }
  # Assign tags for resource organization and management.
  tags = var.tags
}

###############################################################
# Assigns the Key Vault Administrator role to the current user for the created Key Vault.
###############################################################
resource "azurerm_role_assignment" "this" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}
###############################################################
# Local values for constructing resource names and prefixes for private endpoint.
###############################################################
locals {
  name_parts         = split("-", var.name)
  prefixless_name    = slice(local.name_parts, 1, length(local.name_parts) - 1)
  last_part          = local.name_parts[length(local.name_parts) - 1]
  last_part_prefixed = "kv${local.last_part}"
}

###############################################################
# Creates a private endpoint for the Key Vault, enabling secure access from a specified subnet.
###############################################################
resource "azurerm_private_endpoint" "this" {
  name                = "pep-${join("-", concat(local.prefixless_name, [local.last_part_prefixed]))}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = var.tags


  # Defines the private service connection to the Key Vault.
  private_service_connection {
    name                           = "psc-${join("-", concat(local.prefixless_name, [local.last_part_prefixed]))}"
    private_connection_resource_id = azurerm_key_vault.this.id
    is_manual_connection           = false
    subresource_names              = ["Vault"]
  }
  # Optionally configure a static private IP address for the endpoint if provided.
  dynamic "ip_configuration" {
    for_each = var.private_ip_address != null ? [1] : []
    content {
      name               = "ipc-${join("-", concat(local.prefixless_name, [local.last_part_prefixed]))}"
      private_ip_address = var.private_ip_address
      subresource_name   = "Vault"
      member_name        = "default"
    }
  }

  # Optionally link the private endpoint to a private DNS zone group if provided.
  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_group != null ? [1] : []

    content {
      name                 = "link2dnszone"
      private_dns_zone_ids = var.private_dns_zone_group.private_dns_zone_ids
    }
  }
}
