###############################################################
# Outputs the unique resource IDs of all created Network Security Groups (NSGs).
###############################################################
output "id" {
  description = "The unique resource IDs of all NSGs created by this module. Useful for referencing the NSG in other modules or outputs."
  value       = azurerm_network_security_group.this.id
}

###############################################################
# Outputs the names of all created Network Security Groups (NSGs).
###############################################################
output "name" {
  description = "The names of all NSGs created by this module. Useful for display, logging, or referencing in other resources."
  value       = azurerm_network_security_group.this.name
}

###############################################################
# Outputs the security rules applied to each NSG, useful for auditing and validation.
###############################################################
output "security_rule" {
  description = "The security rules applied to each NSG. Useful for auditing and validation."
  value       = azurerm_network_security_group.this.security_rule
}
