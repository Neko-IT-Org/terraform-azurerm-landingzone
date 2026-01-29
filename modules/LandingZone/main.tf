###############################################################
# MODULE: ALZ (Azure Landing Zone)
# Description: Deploy Azure Landing Zone Management Group hierarchy
#              and policy assignments using Azure Verified Module
# Author: Neko-IT-Org
# Version: 1.0.0
###############################################################

###############################################################
# DATA SOURCES
###############################################################
data "azurerm_client_config" "current" {}

data "azapi_client_config" "current" {}

###############################################################
# LOCAL VALUES
###############################################################
locals {
  # Use tenant root if no parent specified
  root_parent_id = coalesce(var.parent_resource_id, data.azapi_client_config.current.tenant_id)

  # Build subscription placement map from individual variables
  platform_subscription_placement = merge(
    var.management_subscription_id != null ? {
      sub-mgmt = {
        subscription_id       = var.management_subscription_id
        management_group_name = "mg-mgmt"
      }
    } : {},
    var.connectivity_subscription_id != null ? {
      sub-con = {
        subscription_id       = var.connectivity_subscription_id
        management_group_name = "mg-con"
      }
    } : {},
    var.identity_subscription_id != null ? {
      sub-idt = {
        subscription_id       = var.identity_subscription_id
        management_group_name = "mg-idt"
      }
    } : {},
    var.security_subscription_id != null ? {
      sub-sec = {
        subscription_id       = var.security_subscription_id
        management_group_name = "mg-sec"
      }
    } : {}
  )

  # Merge platform subscriptions with additional placements
  subscription_placement = merge(
    local.platform_subscription_placement,
    var.additional_subscription_placement
  )

  # Common tags
  common_tags = merge(
    var.tags,
    {
      ManagedBy = "Terraform"
      Module    = "ALZ"
    }
  )
}

###############################################################
# ALZ ARCHITECTURE MODULE
# Description: Deploy Management Group hierarchy and policies
# Source: Azure/avm-ptn-alz/azurerm (Azure Verified Module)
###############################################################
module "alz_architecture" {
  source  = "Azure/avm-ptn-alz/azurerm"
  version = "~> 0.13.0"

  # Architecture configuration
  architecture_name  = var.architecture_name
  parent_resource_id = local.root_parent_id
  location           = var.location

  # Subscription placement
  subscription_placement = local.subscription_placement

  # Policy configuration
  policy_default_values        = var.policy_default_values
  policy_assignments_to_modify = var.policy_assignments_to_modify

  # Role assignments
  management_group_role_assignments = var.management_group_role_assignments

  # Retry configuration
  retries = var.retries

  # Timeout configuration
  timeouts = var.timeouts
}
