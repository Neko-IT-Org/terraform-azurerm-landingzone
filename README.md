# terraform-azurerm-resourcegroup

Terraform module to create and manage an Azure Resource Group with optional tags and lock.

## Usage

```hcl
module "rg" {
  source   = "Neko-IT-Org/resourcegroup/azurerm"
  version  = "***"

  name     = "rg-app-prod-westeurope"
  location = "westeurope"

  tags = {
    environment = "prod"
    owner       = "team"
  }

  lock = {
    kind = "CanNotDelete"
    name = "rg-lock"
  }
}
```
