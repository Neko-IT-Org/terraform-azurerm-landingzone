output "name" {
  value = { for k, s in azurerm_subnet.this : k => s.name }
}
output "id" {
  value = { for k, s in azurerm_subnet.this : k => s.id }
}

output "address_prefixes" {
  value = { for k, s in azurerm_subnet.this : k => s.address_prefixes }
}

output "virtual_network_name" {
  value = var.virtual_network_name
}