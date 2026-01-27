###############################################################
# Map of key objects to create in the Key Vault. Each object defines key properties, options, tags, and optional rotation policy.
###############################################################
variable "keys" {
  description = "Key"
  type = map(object({
    name            = string
    key_type        = string
    key_vault_id    = string
    key_size        = optional(number)
    curve           = optional(string)
    key_opts        = optional(list(string), ["encrypt", "decrypt", "wrapKey", "unwrapKey", "sign", "verify"])
    not_before_date = optional(string)
    expiration_date = optional(string)
    tags            = optional(map(string), {})
    rotation_policy = optional(object({
      expire_after         = optional(string)
      notify_before_expiry = optional(string)
      automatic = optional(object({
        time_after_creation = optional(string)
        time_before_expiry  = optional(string)
      }))
    }))
  }))
}

###############################################################
# Map of tags to merge onto every key for resource organization and management.
###############################################################
variable "tags" {
  description = "Tags to merge on every key."
  type        = map(string)
  default     = {}
}
