###############################################################
# PALO ALTO VM-SERIES VARIABLES
###############################################################

variable "firewall_name" {
  description = "Name of the Palo Alto firewall VM"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

###############################################################
# VM CONFIGURATION
###############################################################
variable "vm_size" {
  description = "VM size for Palo Alto"
  type        = string
  default     = "Standard_D3_v2"
}

variable "palo_version" {
  description = "Palo Alto PAN-OS version"
  type        = string
  default     = "10.2.3"
}

variable "palo_sku" {
  description = "Palo Alto SKU (byol, bundle1, bundle2)"
  type        = string
  default     = "byol"

  validation {
    condition     = contains(["byol", "bundle1", "bundle2"], var.palo_sku)
    error_message = "SKU must be: byol, bundle1, or bundle2."
  }
}

variable "admin_username" {
  description = "Admin username"
  type        = string
  default     = "paadmin"
}

variable "admin_ssh_public_key" {
  description = "SSH public key for admin access"
  type        = string
  sensitive   = true
}

variable "os_disk_type" {
  description = "OS disk type"
  type        = string
  default     = "Premium_LRS"
}

variable "availability_zones" {
  description = "Availability zones for the VM"
  type        = list(string)
  default     = null
}

variable "enable_accelerated_networking" {
  description = "Enable accelerated networking on data interfaces"
  type        = bool
  default     = false
}

###############################################################
# NETWORK CONFIGURATION
###############################################################
variable "mgmt_subnet_id" {
  description = "Management subnet ID"
  type        = string
}

variable "untrust_subnet_id" {
  description = "Untrust subnet ID"
  type        = string
}

variable "trust_subnet_id" {
  description = "Trust subnet ID"
  type        = string
}

variable "mgmt_private_ip" {
  description = "Static private IP for management interface"
  type        = string
  default     = "10.0.1.4"
}

variable "untrust_private_ip" {
  description = "Static private IP for untrust interface"
  type        = string
  default     = "10.0.2.4"
}

variable "trust_private_ip" {
  description = "Static private IP for trust interface"
  type        = string
  default     = "10.0.3.4"
}

###############################################################
# BOOTSTRAP CONFIGURATION
###############################################################
variable "bootstrap_storage_account" {
  description = "Storage account name for bootstrap"
  type        = string
  default     = null
  nullable    = true
}

variable "bootstrap_storage_access_key" {
  description = "Storage account access key"
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "bootstrap_file_share" {
  description = "File share name containing bootstrap files"
  type        = string
  default     = "bootstrap"
}

variable "boot_diagnostics_storage_uri" {
  description = "Boot diagnostics storage URI (optional)"
  type        = string
  default     = null
}
