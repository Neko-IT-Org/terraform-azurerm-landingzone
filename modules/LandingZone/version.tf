###############################################################
# TERRAFORM BLOCK
# Description: Required Terraform and provider versions for ALZ
###############################################################
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    alz = {
      source  = "azure/alz"
      version = "~> 0.17"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
  }
}
