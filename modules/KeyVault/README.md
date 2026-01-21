# Azure Key Vault Terraform Module

This module provisions an Azure Key Vault with configurable access, network, and security settings. It also supports private endpoint integration and role assignment for secure management.

## Features

- Creates an Azure Key Vault with customizable properties
- Assigns the Key Vault Administrator role to the current user
- Supports network ACLs and private endpoint configuration
- Optionally links to private DNS zone groups

## Usage

```hcl
module "keyvault" {
  source = "./KeyVault"

  name                            = "my-keyvault"
  location                        = "westeurope"
  resource_group_name             = "my-resource-group"
  tenant_id                       = "<tenant-id>"
  sku_name                        = "standard"
  enable_rbac                     = true
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = false
  soft_delete_retention_days      = 7
  purge_protection_enabled        = true
  public_network_access_enabled   = false
  subnet_id                       = "<subnet-id>"
  tags = {
    environment = "dev"
    owner       = "your-name"
  }

  # Optional network ACLs
  network_acls = {
    default_action = "Deny"
    bypass        = "AzureServices"
    ip_rules      = ["1.2.3.4"]
    subnet_ids    = ["<subnet-id>"]
  }

  # Optional private DNS zone group
  private_dns_zone_group = {
    private_dns_zone_ids = ["<dns-zone-id>"]
  }

  # Optional static private IP address
  private_ip_address = "10.0.0.5"
}
```

## Inputs

| Name                            | Description                                   | Type   | Required |
| ------------------------------- | --------------------------------------------- | ------ | -------- |
| name                            | Name of the Key Vault                         | string | yes      |
| location                        | Azure region for the Key Vault                | string | yes      |
| resource_group_name             | Resource group name                           | string | yes      |
| tenant_id                       | Azure Active Directory tenant ID              | string | yes      |
| sku_name                        | SKU name (e.g., "standard", "premium")        | string | yes      |
| enable_rbac                     | Enable RBAC authorization                     | bool   | yes      |
| enabled_for_disk_encryption     | Enable disk encryption support                | bool   | yes      |
| enabled_for_deployment          | Enable deployment support                     | bool   | yes      |
| enabled_for_template_deployment | Enable template deployment support            | bool   | yes      |
| soft_delete_retention_days      | Number of days to retain soft-deleted vaults  | number | yes      |
| purge_protection_enabled        | Enable purge protection                       | bool   | yes      |
| public_network_access_enabled   | Enable public network access                  | bool   | yes      |
| subnet_id                       | Subnet ID for private endpoint                | string | yes      |
| tags                            | Map of tags for resource organization         | map    | no       |
| network_acls                    | Network ACLs configuration (object)           | object | no       |
| private_dns_zone_group          | Private DNS zone group configuration (object) | object | no       |
| private_ip_address              | Static private IP address for the endpoint    | string | no       |

## Outputs

| Name | Description               |
| ---- | ------------------------- |
| id   | The Key Vault resource ID |
| name | The Key Vault name        |

## Resources

- `azurerm_key_vault`
- `azurerm_role_assignment`
- `azurerm_private_endpoint`

## Example

See the usage section above for a sample configuration.

## License

POST
