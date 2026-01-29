###############################################################
# ALZ PROVIDER CONFIGURATION
# Description: Configure the ALZ provider with library references
#              and custom overrides
###############################################################
provider "alz" {
  # Enable library overwrite for custom archetypes
  library_overwrite_enabled = true

  # Library references - order matters (later overrides earlier)
  library_references = [
    {
      path = "platform/alz"
      ref  = "2025.02.0"
    },
    {
      path = "platform/amba"
      ref  = "2025.05.0"
    },
    {
      # Custom library with archetype overrides
      custom_url = "${path.root}/lib"
    }
  ]
}
