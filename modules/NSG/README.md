# Azure Network Security Group (NSG) Terraform Module

This module provisions an Azure Network Security Group (NSG) with customizable security rules and tagging for resource management.

## Features

- Creates an Azure NSG in a specified resource group and location
- Supports a list of security rules with flexible configuration
- Allows custom tags for resource organization

## Usage

```hcl
module "nsg" {
  source = "./NSG"

  name                = "my-nsg"
  location            = "westeurope"
  resource_group_name = "my-resource-group"
  tags = {
    environment = "dev"
    owner       = "your-name"
  }

  security_rules = [
    {
      name                       = "AllowSSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      source_port_range          = "*"
      destination_port_range     = "22"
      description                = "Allow SSH access"
    }
  ]
}
```

## Inputs

| Name                | Description                                            | Type         | Required |
| ------------------- | ------------------------------------------------------ | ------------ | -------- |
| name                | Name of the NSG                                        | string       | yes      |
| location            | Azure region for the NSG                               | string       | yes      |
| resource_group_name | Resource group name                                    | string       | yes      |
| tags                | Map of tags for resource organization                  | map(string)  | no       |
| security_rules      | List of security rule objects to be applied to the NSG | list(object) | no       |

## Outputs

| Name          | Description                            |
| ------------- | -------------------------------------- |
| id            | The unique resource IDs of all NSGs    |
| name          | The names of all NSGs                  |
| security_rule | The security rules applied to each NSG |

## Resources

- `azurerm_network_security_group`
- `time_static`

## Example

See the usage section above for a sample configuration.

## License

MIT
