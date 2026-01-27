# Azure Key Vault Key Terraform Module

This module provisions one or more keys in an Azure Key Vault, supporting advanced configuration such as key rotation policies, custom tags, and flexible key options.

## Features

- Creates multiple keys in a specified Azure Key Vault
- Supports key rotation policies and automatic rotation
- Allows custom tags for each key
- Configurable key types, sizes, curves, and options

## Usage

```hcl
module "keyvault_key" {
  source = "./KeyVault-Key"

  keys = {
    mykey1 = {
      name         = "mykey1"
      key_type     = "RSA"
      key_vault_id = azurerm_key_vault.example.id
      key_size     = 2048
      key_opts     = ["encrypt", "decrypt"]
      tags = {
        environment = "dev"
      }
      rotation_policy = {
        expire_after         = "P2Y"
        notify_before_expiry = "P30D"
        automatic = {
          time_after_creation = "P1Y"
        }
      }
    }
  }

  tags = {
    owner = "your-name"
  }
}
```

## Inputs

| Name | Description                                                                                                                     | Type        | Required |
| ---- | ------------------------------------------------------------------------------------------------------------------------------- | ----------- | -------- |
| keys | Map of key objects to create in the Key Vault. Each object defines key properties, options, tags, and optional rotation policy. | map(object) | yes      |
| tags | Map of tags to merge onto every key for resource organization and management.                                                   | map(string) | no       |

## Outputs

| Name            | Description                                      |
| --------------- | ------------------------------------------------ |
| keys            | Full azurerm_key_vault_key resources by key name |
| ids             | Key IDs (versioned)                              |
| versionless_ids | Key IDs without version (for auto-rotation)      |

## Resources

- `azurerm_key_vault_key`
- `time_static`
- `time_offset`

## Example

See the usage section above for a sample configuration.

## License

POST
