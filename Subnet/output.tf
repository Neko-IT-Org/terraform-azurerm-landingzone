output "name" {
  value = { for k, s in azurerm_subnet.this : k => s.name }
}
output "id" {
  value = { for k, s in azurerm_subnet.this : k => s.id }
}
