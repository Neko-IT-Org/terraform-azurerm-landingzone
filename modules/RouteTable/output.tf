###############################################################
# Outputs the unique resource IDs of all created Azure Route Tables.
###############################################################
output "route_table_id" {
  description = "The unique resource IDs of all route tables created by this module. Useful for referencing the route table in other modules or outputs."
  value       = azurerm_route_table.this.id
}

###############################################################
# Outputs the names of all created Azure Route Tables.
###############################################################
output "route_table_name" {
  description = "The names of all route tables created by this module. Useful for display, logging, or referencing in other resources."
  value       = azurerm_route_table.this.name
}

###############################################################
# Outputs the route definitions applied to each route table, useful for auditing and validation.
###############################################################
output "route_table_route" {
  description = "The route definitions applied to each route table. Useful for auditing and validation."
  value       = azurerm_route_table.this.route
}
