# Vnet Terraform Module

This module creates an Azure Virtual Network (VNet) with optional DDoS protection, DNS servers, and IPAM pool support.

## Features

- Creates a single Azure VNet
- Supports custom address space and DNS servers
- Optional DDoS protection plan association
- Optional IPAM pool configuration
- Tags resources, including a creation timestamp

## Usage

```hcl
module "vnet" {
  source                = "./modules/Vnet"
  name                  = "my-vnet"
  location              = "westeurope"
  resource_group_name   = "my-rg"
  address_space         = ["10.0.0.0/16"]
  dns_servers           = ["8.8.8.8", "8.8.4.4"]
  ddos_protection_plan_id = azurerm_ddos_protection_plan.ddos.id
  tags = {
    environment = "prod"
    owner       = "team"
  }
  ip_address_pool = {
    id                     = "ipam-pool-id"
    number_of_ip_addresses = 256
  }
}
```

## Input Variables

- `name` (string): Name of the virtual network
- `location` (string): Azure region
- `resource_group_name` (string): Resource group name
- `address_space` (list(string), optional): CIDR blocks for the VNet
- `dns_servers` (list(string), optional): DNS server IPs
- `ddos_protection_plan_id` (string): DDoS protection plan ID
- `tags` (map(string)): Tags to apply to the VNet
- `ip_address_pool` (object, optional): IPAM pool configuration

## Outputs

- `id`: VNet resource ID
- `name`: VNet name

## Recommendations & Best Practices

- **Variable Descriptions:** Update variable descriptions to reference the virtual network, not resource group.
- **Type Consistency:** Use `number` for `ip_address_pool.number_of_ip_addresses`.
- **Conditional DDoS Protection:** Add a variable to enable/disable DDoS protection.
- **Tagging:** Use a proper timestamp for the `CreatedOn` tag (e.g., `time_static.time.rfc3339`).
- **Resource Count:** If you need multiple VNets, refactor to use `for_each` or `count`.
- **Outputs:** Use direct references for outputs if only one VNet is created.

## Requirements

- Terraform >= 1.0
- AzureRM provider >= 3.0

## License

POST
