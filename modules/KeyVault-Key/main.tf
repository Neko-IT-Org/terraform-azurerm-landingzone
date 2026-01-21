###############################################################
# Captures the time when Terraform is first applied, used for key creation and expiry calculations.
###############################################################
resource "time_static" "created_at" {}

###############################################################
# Calculates a date two years after creation, used as a default key expiry.
###############################################################
resource "time_offset" "expiry_plus_2y" {
  base_rfc3339 = time_static.created_at.rfc3339
  offset_years = 2
}

###############################################################
# Creates one or more Azure Key Vault keys with optional rotation policy and expiry settings.
###############################################################
resource "azurerm_key_vault_key" "this" {
  for_each = var.keys

  name         = each.value.name
  key_vault_id = each.value.key_vault_id

  key_type        = each.value.key_type
  key_size        = try(each.value.key_size, null)
  curve           = try(each.value.curve, null)
  key_opts        = try(each.value.key_opts, null)
  not_before_date = try(each.value.not_before_date, null)
  expiration_date = coalesce(
    try(each.value.expiration_date, null),
    time_offset.expiry_plus_2y.rfc3339
  )

  tags = merge(var.tags, try(each.value.tags, {}))

  # Optionally configures a rotation policy for each key if provided.
  dynamic "rotation_policy" {
    for_each = each.value.rotation_policy == null ? [] : [each.value.rotation_policy]
    content {
      expire_after         = try(each.value.rotation_policy.expire_after, null)
      notify_before_expiry = try(each.value.rotation_policy.notify_before_expiry, null)
      # Optionally configures automatic rotation settings if provided.
      dynamic "automatic" {
        for_each = each.value.rotation_policy.automatic == null ? [] : [each.value.rotation_policy.automatic]
        content {
          time_after_creation = try(each.value.rotation_policy.automatic.time_after_creation, null)
          time_before_expiry  = try(each.value.rotation_policy.automatic.time_before_expiry, null)
        }
      }
    }
  }
}
