###############################################################
# MODULE: ALZ - Outputs
# Description: Outputs for Management Group hierarchy and policies
###############################################################

###############################################################
# MANAGEMENT GROUPS
###############################################################
output "management_group_resource_ids" {
  description = "Map of management group names to their resource IDs"
  value       = module.alz_architecture.management_group_resource_ids
}

###############################################################
# POLICY OUTPUTS
###############################################################
output "policy_assignment_resource_ids" {
  description = "Map of policy assignment names to their resource IDs"
  value       = module.alz_architecture.policy_assignment_resource_ids
}

output "policy_assignment_identity_ids" {
  description = "Map of policy assignment names to their managed identity IDs"
  value       = module.alz_architecture.policy_assignment_identity_ids
}

output "policy_definition_resource_ids" {
  description = "Map of policy definition names to their resource IDs"
  value       = module.alz_architecture.policy_definition_resource_ids
}

output "policy_set_definition_resource_ids" {
  description = "Map of policy set definition names to their resource IDs"
  value       = module.alz_architecture.policy_set_definition_resource_ids
}

###############################################################
# ROLE OUTPUTS
###############################################################
output "role_definition_resource_ids" {
  description = "Map of role definition names to their resource IDs"
  value       = module.alz_architecture.role_definition_resource_ids
}

###############################################################
# CONVENIENCE OUTPUTS - MANAGEMENT GROUP IDs
###############################################################
output "root_management_group_id" {
  description = "Resource ID of the root management group (mg-lzr)"
  value       = lookup(module.alz_architecture.management_group_resource_ids, "mg-lzr", null)
}

output "landing_zones_management_group_id" {
  description = "Resource ID of the Landing Zones management group (mg-lz)"
  value       = lookup(module.alz_architecture.management_group_resource_ids, "mg-lz", null)
}

output "platform_management_group_id" {
  description = "Resource ID of the Platform management group (mg-plat)"
  value       = lookup(module.alz_architecture.management_group_resource_ids, "mg-plat", null)
}

output "management_management_group_id" {
  description = "Resource ID of the Management management group (mg-mgmt)"
  value       = lookup(module.alz_architecture.management_group_resource_ids, "mg-mgmt", null)
}

output "connectivity_management_group_id" {
  description = "Resource ID of the Connectivity management group (mg-con)"
  value       = lookup(module.alz_architecture.management_group_resource_ids, "mg-con", null)
}

output "identity_management_group_id" {
  description = "Resource ID of the Identity management group (mg-idt)"
  value       = lookup(module.alz_architecture.management_group_resource_ids, "mg-idt", null)
}

output "security_management_group_id" {
  description = "Resource ID of the Security management group (mg-sec)"
  value       = lookup(module.alz_architecture.management_group_resource_ids, "mg-sec", null)
}

output "corp_management_group_id" {
  description = "Resource ID of the Corp management group (mg-corp)"
  value       = lookup(module.alz_architecture.management_group_resource_ids, "mg-corp", null)
}

output "online_management_group_id" {
  description = "Resource ID of the Online management group (mg-online)"
  value       = lookup(module.alz_architecture.management_group_resource_ids, "mg-online", null)
}

output "sandbox_management_group_id" {
  description = "Resource ID of the Sandbox management group (mg-sandbox)"
  value       = lookup(module.alz_architecture.management_group_resource_ids, "mg-sandbox", null)
}

output "decommissioned_management_group_id" {
  description = "Resource ID of the Decommissioned management group (mg-decommissioned)"
  value       = lookup(module.alz_architecture.management_group_resource_ids, "mg-decommissioned", null)
}

###############################################################
# SUMMARY OUTPUT
###############################################################
output "alz_summary" {
  description = "Summary of deployed ALZ architecture"
  value = {
    architecture_name = var.architecture_name
    location          = var.location
    parent_id         = local.root_parent_id

    management_groups = {
      total_count = length(module.alz_architecture.management_group_resource_ids)
      names       = keys(module.alz_architecture.management_group_resource_ids)
    }

    subscriptions_placed = {
      count       = length(local.subscription_placement)
      placements  = local.subscription_placement
    }

    policies = {
      assignments_count     = length(module.alz_architecture.policy_assignment_resource_ids)
      definitions_count     = length(module.alz_architecture.policy_definition_resource_ids)
      set_definitions_count = length(module.alz_architecture.policy_set_definition_resource_ids)
    }

    roles = {
      definitions_count = length(module.alz_architecture.role_definition_resource_ids)
    }
  }
}
