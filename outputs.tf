###############################################################
# ROOT OUTPUTS.TF
# Description: Outputs principaux de l'infrastructure
###############################################################

###############################################################
# RESOURCE GROUPS
###############################################################
output "resource_group_hub_id" {
  description = "Hub resource group ID"
  value       = module.rg_hub.id
}

output "resource_group_hub_name" {
  description = "Hub resource group name"
  value       = module.rg_hub.name
}

output "resource_group_spoke_app_id" {
  description = "Spoke App resource group ID"
  value       = module.rg_spoke_app.id
}

output "resource_group_spoke_data_id" {
  description = "Spoke Data resource group ID"
  value       = module.rg_spoke_data.id
}

###############################################################
# VNETS
###############################################################
output "vnet_hub_id" {
  description = "Hub VNet ID"
  value       = module.vnet_hub.id
}

output "vnet_hub_name" {
  description = "Hub VNet name"
  value       = module.vnet_hub.name
}

output "vnet_spoke_app_id" {
  description = "Spoke App VNet ID"
  value       = module.vnet_spoke_app.id
}

output "vnet_spoke_data_id" {
  description = "Spoke Data VNet ID"
  value       = module.vnet_spoke_data.id
}

###############################################################
# SUBNETS
###############################################################
output "hub_subnet_ids" {
  description = "Map of Hub subnet names to IDs"
  value       = module.subnets_hub.id
}

output "spoke_app_subnet_ids" {
  description = "Map of Spoke App subnet names to IDs"
  value       = module.subnets_spoke_app.id
}

output "spoke_data_subnet_ids" {
  description = "Map of Spoke Data subnet names to IDs"
  value       = module.subnets_spoke_data.id
}

###############################################################
# NETWORK SECURITY GROUPS
###############################################################
output "nsg_hub_mgmt_id" {
  description = "Hub Management NSG ID"
  value       = module.nsg_hub_mgmt.id
}

output "nsg_hub_untrust_id" {
  description = "Hub Untrust NSG ID"
  value       = module.nsg_hub_untrust.id
}

output "nsg_hub_trust_id" {
  description = "Hub Trust NSG ID"
  value       = module.nsg_hub_trust.id
}

###############################################################
# ROUTE TABLES
###############################################################
output "route_table_spoke_to_firewall_id" {
  description = "Route table ID for spoke-to-firewall routing"
  value       = module.rt_spoke_to_firewall.route_table_id
}

output "route_table_routes" {
  description = "Configured routes in the spoke route table"
  value       = module.rt_spoke_to_firewall.route_table_route
}

###############################################################
# PEERINGS
###############################################################
output "peering_hub_to_spoke_app_ids" {
  description = "Peering IDs between Hub and Spoke App"
  value       = module.peering_hub_to_spoke_app.all_peering_ids
}

output "peering_hub_to_spoke_data_ids" {
  description = "Peering IDs between Hub and Spoke Data"
  value       = module.peering_hub_to_spoke_data.all_peering_ids
}

output "peering_states" {
  description = "All peering states for validation"
  value = {
    hub_to_spoke_app = {
      forward = module.peering_hub_to_spoke_app.peering_states
      reverse = module.peering_hub_to_spoke_app.reverse_peering_states
    }
    hub_to_spoke_data = {
      forward = module.peering_hub_to_spoke_data.peering_states
      reverse = module.peering_hub_to_spoke_data.reverse_peering_states
    }
  }
}

###############################################################
# INFRASTRUCTURE SUMMARY
###############################################################
output "infrastructure_summary" {
  description = "High-level summary of deployed infrastructure"
  value = {
    location    = var.location
    hub_vnet = {
      name          = module.vnet_hub.name
      address_space = "10.0.0.0/16"
      subnets       = keys(module.subnets_hub.id)
    }
    spoke_app_vnet = {
      name          = module.vnet_spoke_app.name
      address_space = "10.1.0.0/16"
      subnets       = keys(module.subnets_spoke_app.id)
    }
    spoke_data_vnet = {
      name          = module.vnet_spoke_data.name
      address_space = "10.2.0.0/16"
      subnets       = keys(module.subnets_spoke_data.id)
    }
  }
}

###############################################################
# NEXT STEPS
###############################################################
output "next_steps" {
  description = "Recommended next steps after deployment"
  value = <<-EOT
  
  ✅ Infrastructure deployed successfully!
  
  📋 Next Steps:
  1. Deploy Palo Alto VM-Series firewall in Hub VNet
  2. Configure firewall policies via Panorama or local UI
  3. Deploy workload resources in spoke VNets
  4. Verify routing: Spoke -> Firewall Trust ()
  5. Test connectivity between spokes via firewall
  
  📊 To view all peering states:
     terraform output peering_states
  
  🔍 To access Hub Management subnet:
     ssh paadmin@<firewall-mgmt-public-ip> -i <your-ssh-key>
  
  EOT
}
