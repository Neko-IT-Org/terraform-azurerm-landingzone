# Azure Infrastructure Terraform - Palo Alto Hub-and-Spoke

Terraform infrastructure-as-code for deploying a secure Azure Hub-and-Spoke architecture with Palo Alto VM-Series firewall.

## Architecture

```
Hub VNet (10.0.0.0/16)
├── Management Subnet (10.0.0.0/26) - Palo Alto eth0
├── Untrust Subnet (10.0.1.0/26)    - Palo Alto eth1/1 (Public)
└── Trust Subnet (10.0.2.0/26)      - Palo Alto eth1/2 (Private)
    ↓
Spoke VNets (10.x.0.0/16)
└── All traffic routed through firewall
```

## Modules

| Module                                    | Description                                   |
| ----------------------------------------- | --------------------------------------------- |
| [resourcegroup](./modules/resourcegroup/) | Azure Resource Group with locks and RBAC      |
| [Vnet](./modules/Vnet/)                   | Virtual Network with DDoS and DNS support     |
| [Subnet](./modules/Subnet/)               | Subnets with NSG and Route Table associations |
| [NSG](./modules/NSG/)                     | Network Security Groups with rules            |
| [RouteTable](./modules/RouteTable/)       | Route Tables for traffic steering             |

## Prerequisites

- Terraform >= 1.5.0
- Azure CLI authenticated
- Appropriate Azure permissions

## Quick Start

```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply
```

## Structure

```
.
├── modules/
│   ├── resourcegroup/
│   ├── Vnet/
│   ├── Subnet/
│   ├── NSG/
│   └── RouteTable/
├── main.tf           # Root configuration (create this)
├── variables.tf      # Root variables (create this)
├── outputs.tf        # Root outputs (create this)
└── README.md
```

## Key Features

- **Modular Design**: Reusable modules for each Azure resource type
- **Automatic Tagging**: All resources tagged with `CreatedOn` timestamp
- **Validation**: Built-in validation for Azure naming and configuration rules
- **Hub-and-Spoke Ready**: Designed for firewall-based network architecture
- **BGP Awareness**: Configurable BGP propagation to avoid routing loops

## Naming Convention

`<resource>-<project>-<env>-<region>-<index>`

Examples:

- `rg-neko-lab-weu-01`
- `vnet-hub-prod-weu-01`
- `nsg-mgmt-hub-weu-01`

## Security Considerations

- NSG rules follow least privilege principle
- Management subnets isolated with strict NSG
- No default routes without explicit firewall inspection
- BGP propagation disabled in spokes to prevent loops

## Next Steps

1. Create `main.tf` with your infrastructure code
2. Define variables in `variables.tf`
3. Configure outputs in `outputs.tf`
4. Deploy Palo Alto VM-Series
5. Configure bootstrap storage account

## License

MIT

## Authors

Neko-IT-Org
