# Azure Route Table Terraform Module

This module provisions an Azure Route Table with customizable routes and tagging for resource management.

## Features
- Creates an Azure Route Table in a specified resource group and location
- Supports a list of custom routes
- Allows custom tags for resource organization
- Optionally enables BGP route propagation

## Usage
```hcl
module "route_table" {
  source = "./RT"

  name                = "my-route-table"
  location            = "westeurope"
  resource_group_name = "my-resource-group"
  bgp_route_propagation_enabled = true
  tags = {
    environment = "dev"
    owner       = "your-name"
  }

  route = [
    {
      name            = "route1"
      address_prefix  = "10.0.0.0/16"
      next_hop_type   = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4"
    }
  ]
}
```

## Inputs
| Name                        | Description                                                      | Type         | Required |
|-----------------------------|------------------------------------------------------------------|--------------|----------|
| name                        | Name of the route table                                          | string       | yes      |
| location                    | Azure region for the route table                                 | string       | yes      |
| resource_group_name         | Resource group name                                              | string       | yes      |
| bgp_route_propagation_enabled | Whether BGP route propagation is enabled for the route table   | bool         | no       |
| route                       | List of route objects to be added to the route table             | list(object) | yes      |
| tags                        | Map of tags for resource organization                            | map(string)  | no       |

## Outputs
| Name             | Description                                         |
|------------------|-----------------------------------------------------|
| route_table_id   | The unique resource IDs of all route tables         |
| route_table_name | The names of all route tables                       |
| route_table_route| The route definitions applied to each route table   |

## Resources
- `azurerm_route_table`
- `time_static`

## Example
See the usage section above for a sample configuration.

## License
MIT
