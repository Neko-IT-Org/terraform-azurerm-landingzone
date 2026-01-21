output "name" {
  value = { for k, s in azurerm_subnet.this : k => s.id }
}
output "id" {
  value = { for k, s in azurerm_subnet.this : k => s.name }
}
