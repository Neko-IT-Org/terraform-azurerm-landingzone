###############################################################
# MODULE: ALZ (Azure Landing Zone) - Variables
# Description: Variables for Management Group hierarchy and policy deployment
###############################################################

###############################################################
# REQUIRED VARIABLES
###############################################################
variable "location" {
  description = "Primary Azure region for ALZ resources"
  type        = string

  validation {
    condition = contains([
      "westeurope", "northeurope", "eastus", "eastus2", "westus", "westus2",
      "centralus", "francecentral", "germanywestcentral", "uksouth", "ukwest",
      "southeastasia", "eastasia", "australiaeast", "japaneast"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

###############################################################
# ARCHITECTURE CONFIGURATION
###############################################################
variable "architecture_name" {
  description = "Name of the ALZ architecture definition (must match file in lib/)"
  type        = string
  default     = "prod"

  validation {
    condition     = can(regex("^[a-z0-9_-]+$", var.architecture_name))
    error_message = "Architecture name must contain only lowercase letters, numbers, hyphens, and underscores."
  }
}

variable "parent_resource_id" {
  description = "Parent resource ID for the root management group (tenant root or existing MG)"
  type        = string
  default     = null
}

###############################################################
# SUBSCRIPTION PLACEMENT
###############################################################
variable "management_subscription_id" {
  description = "Subscription ID for Management workloads"
  type        = string
  default     = null

  validation {
    condition     = var.management_subscription_id == null || can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.management_subscription_id))
    error_message = "Subscription ID must be a valid GUID."
  }
}

variable "connectivity_subscription_id" {
  description = "Subscription ID for Connectivity workloads"
  type        = string
  default     = null

  validation {
    condition     = var.connectivity_subscription_id == null || can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.connectivity_subscription_id))
    error_message = "Subscription ID must be a valid GUID."
  }
}

variable "identity_subscription_id" {
  description = "Subscription ID for Identity workloads"
  type        = string
  default     = null

  validation {
    condition     = var.identity_subscription_id == null || can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.identity_subscription_id))
    error_message = "Subscription ID must be a valid GUID."
  }
}

variable "security_subscription_id" {
  description = "Subscription ID for Security workloads"
  type        = string
  default     = null

  validation {
    condition     = var.security_subscription_id == null || can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.security_subscription_id))
    error_message = "Subscription ID must be a valid GUID."
  }
}

variable "additional_subscription_placement" {
  description = "Additional subscription placements (e.g., corp subscriptions)"
  type = map(object({
    subscription_id       = string
    management_group_name = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.additional_subscription_placement :
      can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", v.subscription_id))
    ])
    error_message = "All subscription IDs must be valid GUIDs."
  }
}

###############################################################
# POLICY DEFAULT VALUES
###############################################################
variable "policy_default_values" {
  description = "Default values for policy parameters across all assignments"
  type        = map(string)
  default     = {}
}

###############################################################
# POLICY ASSIGNMENTS TO MODIFY
###############################################################
variable "policy_assignments_to_modify" {
  description = "Policy assignments to modify per management group"
  type = map(object({
    policy_assignments = map(object({
      enforcement_mode = optional(string)
      identity         = optional(string)
      identity_ids     = optional(list(string))
      parameters       = optional(map(string))
      resource_selectors = optional(list(object({
        name = string
        selectors = list(object({
          kind   = string
          in     = optional(list(string))
          not_in = optional(list(string))
        }))
      })))
      non_compliance_messages = optional(list(object({
        message                        = string
        policy_definition_reference_id = optional(string)
      })))
    }))
  }))
  default = {}
}

###############################################################
# ROLE ASSIGNMENTS
###############################################################
variable "management_group_role_assignments" {
  description = "Role assignments to create on management groups"
  type = map(map(object({
    principal_id                           = string
    role_definition_name                   = optional(string)
    role_definition_id                     = optional(string)
    description                            = optional(string)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string)
    condition_version                      = optional(string)
    delegated_managed_identity_resource_id = optional(string)
    principal_type                         = optional(string)
  })))
  default = {}
}

###############################################################
# HIERARCHY SETTINGS
###############################################################
variable "hierarchy_settings" {
  description = "Management Group hierarchy settings"
  type = object({
    default_management_group_name         = optional(string)
    require_authorization_for_group_creation = optional(bool)
    update_existing                       = optional(bool, true)
  })
  default = null
}

###############################################################
# TIMEOUTS AND RETRIES
###############################################################
variable "retries" {
  description = "Retry configuration for Azure API calls"
  type = object({
    management_groups = optional(object({
      error_message_regex = optional(list(string), [
        "AuthorizationFailed",
        "InsufficientPermissions"
      ])
      interval_seconds     = optional(number, 10)
      max_interval_seconds = optional(number, 60)
      multiplier           = optional(number, 2)
      randomization_factor = optional(number, 0.5)
    }))
    policy_assignments = optional(object({
      error_message_regex = optional(list(string), [
        "AuthorizationFailed",
        "PolicyDefinitionNotFound",
        "PolicySetDefinitionNotFound"
      ])
      interval_seconds     = optional(number, 10)
      max_interval_seconds = optional(number, 60)
      multiplier           = optional(number, 2)
      randomization_factor = optional(number, 0.5)
    }))
    role_assignments = optional(object({
      error_message_regex = optional(list(string), [
        "AuthorizationFailed",
        "PrincipalNotFound"
      ])
      interval_seconds     = optional(number, 10)
      max_interval_seconds = optional(number, 60)
      multiplier           = optional(number, 2)
      randomization_factor = optional(number, 0.5)
    }))
  })
  default = {}
}

variable "timeouts" {
  description = "Timeout configuration for resource operations"
  type = object({
    management_group = optional(object({
      create = optional(string, "10m")
      delete = optional(string, "10m")
      update = optional(string, "10m")
      read   = optional(string, "5m")
    }))
    policy_assignment = optional(object({
      create = optional(string, "10m")
      delete = optional(string, "10m")
      update = optional(string, "10m")
      read   = optional(string, "5m")
    }))
    policy_definition = optional(object({
      create = optional(string, "5m")
      delete = optional(string, "5m")
      update = optional(string, "5m")
      read   = optional(string, "5m")
    }))
    policy_set_definition = optional(object({
      create = optional(string, "5m")
      delete = optional(string, "5m")
      update = optional(string, "5m")
      read   = optional(string, "5m")
    }))
    role_assignment = optional(object({
      create = optional(string, "5m")
      delete = optional(string, "5m")
      update = optional(string, "5m")
      read   = optional(string, "5m")
    }))
    role_definition = optional(object({
      create = optional(string, "5m")
      delete = optional(string, "5m")
      update = optional(string, "5m")
      read   = optional(string, "5m")
    }))
  })
  default = {}
}

###############################################################
# TAGS
###############################################################
variable "tags" {
  description = "Tags to apply to ALZ resources where supported"
  type        = map(string)
  default     = {}
}
