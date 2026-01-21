###############################################################
# Outputs the full azurerm_key_vault_key resources for each key, allowing access to all attributes.
###############################################################
output "keys" {
  description = "Full azurerm_key_vault_key resources by key map key."
  value       = azurerm_key_vault_key.this
}

###############################################################
# Outputs the versioned IDs for each Key Vault key, useful for referencing specific key versions.
###############################################################
output "ids" {
  description = "Key IDs (versioned)."
  value       = { for k, v in azurerm_key_vault_key.this : k => v.id }
}

###############################################################
# Outputs the versionless IDs for each Key Vault key, useful for consumers needing auto-rotation.
###############################################################
output "versionless_ids" {
  description = "Key IDs without version (useful for CMK auto-rotation consumers)."
  value       = { for k, v in azurerm_key_vault_key.this : k => v.versionless_id }
}
