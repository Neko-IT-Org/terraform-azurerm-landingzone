# Outputs the unique resource IDs of all created Azure Virtual Networks (VNets).
output "id" {
  description = "The unique resource IDs of VNets created by this module."
  value       = azurerm_virtual_network.this.id
}

# Outputs the names of all created Azure Virtual Networks (VNets).
output "name" {
  description = "The names of the VNets created by this module."
  value       = azurerm_virtual_network.this.name
}
