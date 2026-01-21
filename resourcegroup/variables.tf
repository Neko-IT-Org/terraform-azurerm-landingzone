# Name of the resource group to be created.
# Should include environment code, be 90 characters or less, and only contain alphanumeric, '-', or '_' characters.
variable "name" {
  type        = string
  description = "Required. The name of the this resource."

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 90 && can(regex("^[a-zA-Z0-9_().-]+$", var.name)) && !endswith(var.name, ".")
    error_message = <<ERROR_MESSAGE
    The resource group name must meet the following requirements:
    - `Between 1 and 90 characters long.` 
    - `Can only contain Alphanumerics, underscores, parentheses, hyphens, periods.`
    - `Cannot end in a period`
    ERROR_MESSAGE
  }
}

# Location where the resource group will be deployed (e.g., 'westeurope').
variable "location" {
  description = "The location of the resource"
  type        = string
}

# Map of tags to assign to the resource group for organization and cost management.
variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# Enable management lock on the resource group for protection against accidental deletion.
variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
  Controls the Resource Lock configuration for this resource. The following properties can be specified:
  
  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
  DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
}

variable "role_assignments" {
  description = <<EOT
Optional role assignments at RG scope.
Example:
[
  { principal_id = "00000000-0000-0000-0000-000000000000", role_definition_id = "/providers/Microsoft.Authorization/roleDefinitions/<role-guid>" }
]
EOT
  type = list(object({
    principal_id                           = string
    role_definition_id                     = optional(string)
    role_definition_name                   = optional(string)
    condition                              = optional(string)
    condition_version                      = optional(string)
    description                            = optional(string)
    delegated_managed_identity_resource_id = optional(string)
  }))
  default = []
  validation {
    condition = alltrue([
      for assignment in var.role_assignments :
      (
        (!isnull(assignment.role_definition_id) && isnull(assignment.role_definition_name)) ||
        (isnull(assignment.role_definition_id) && !isnull(assignment.role_definition_name))
      )
    ])

    error_message = <<EOT
Each role assignment must specify exactly one of `role_definition_id` or `role_definition_name`. Remove the extra attribute if both are provided, or supply the missing one.
EOT
  }
}
