# Output the ID of the resource group for use in other modules or root outputs.
output "id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.this.id
}

# Output the name of the resource group for reference or reuse.
output "name" {
  description = "The Name of the resource group"
  value       = azurerm_resource_group.this.name
}

# Output the location of the resource group for location-based logic or deployments.
output "location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.this.location
}

# Output all tags applied to the resource group for auditing or downstream usage.
output "tags" {
  description = "The complete tags applied to the resource group"
  value       = azurerm_resource_group.this.tags
}
