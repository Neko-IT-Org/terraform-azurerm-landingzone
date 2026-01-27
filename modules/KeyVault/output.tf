# output.tf
output "id" {
  value = azurerm_key_vault.this.id
}

output "uri" {
  value = azurerm_key_vault.this.vault_uri
}

output "name" {
  value = azurerm_key_vault.this.name
}

output "ip_address" {
  value = try(azurerm_private_endpoint.this.private_service_connection[0].private_ip_address, null)
}