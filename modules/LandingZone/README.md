# 🏗️ ALZ Module (Azure Landing Zone)

Terraform module to deploy **Azure Landing Zone Management Group hierarchy** and **policy assignments** using the Azure Verified Module (`Azure/avm-ptn-alz/azurerm`).

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Usage](#-usage)
- [Library Structure](#-library-structure)
- [Variables](#-variables)
- [Outputs](#-outputs)
- [Examples](#-examples)
- [Troubleshooting](#-troubleshooting)

---

## 🎯 Overview

This module deploys the **Azure Landing Zone** foundation including:

- **Management Group Hierarchy** - Organized structure for governance
- **Policy Definitions** - Custom and built-in policies
- **Policy Assignments** - Automated compliance enforcement
- **Role Definitions** - Custom RBAC roles
- **Subscription Placement** - Automatic subscription organization
- **AMBA Integration** - Azure Monitor Baseline Alerts

---

## 🏛️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Tenant Root Group                         │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│              Landing Zone Root (mg-lzr)                      │
│              • Root policies                                 │
│              • AMBA notifications                            │
└───────────┬─────────────────────────────────┬───────────────┘
            │                                 │
┌───────────▼───────────┐       ┌─────────────▼─────────────┐
│   Landing Zones       │       │      Platform             │
│      (mg-lz)          │       │      (mg-plat)            │
│  • Landing zone       │       │  • Platform policies      │
│    policies           │       │  • DDoS protection        │
└─────┬─────────────────┘       └─────────┬─────────────────┘
      │                                   │
      ├── Corp (mg-corp)                  ├── Management (mg-mgmt)
      │   • Corp subscriptions            │   • Log Analytics
      │                                   │   • Automation
      ├── Online (mg-online)              │
      │   • Public-facing apps            ├── Connectivity (mg-con)
      │                                   │   • Hub VNet
      ├── Sandbox (mg-sandbox)            │   • Firewall
      │   • Dev/Test                      │   • VPN Gateway
      │                                   │
      └── Decommissioned                  ├── Identity (mg-idt)
          (mg-decommissioned)             │   • AD DS
                                          │   • Identity services
                                          │
                                          └── Security (mg-sec)
                                              • Security tools
                                              • SIEM
```

---

## ✨ Features

- ✅ **Azure Verified Module** - Uses official `Azure/avm-ptn-alz/azurerm`
- ✅ **Custom Library** - Override archetypes and policies
- ✅ **AMBA Integration** - Azure Monitor Baseline Alerts included
- ✅ **Flexible Subscription Placement** - Platform + additional subscriptions
- ✅ **Policy Customization** - Modify parameters and enforcement
- ✅ **Retry Logic** - Handle transient Azure API errors

---

## 📦 Prerequisites

### Tools

| Tool       | Version   | Description              |
| ---------- | --------- | ------------------------ |
| Terraform  | ≥ 1.9.0   | Infrastructure as Code   |
| Azure CLI  | ≥ 2.50    | Azure authentication     |

### Permissions

- **Global Administrator** or **Owner** at tenant root
- For subscription placement: **Owner** on target subscriptions

### Authentication

```bash
# Login to Azure
az login

# Set subscription (for state management)
az account set --subscription "Management-Subscription"
```

---

## 🚀 Usage

### Basic Usage

```hcl
module "alz" {
  source = "./modules/ALZ"

  # Required
  location = "westeurope"

  # Architecture
  architecture_name = "prod"

  # Platform subscriptions
  management_subscription_id   = "00000000-0000-0000-0000-000000000001"
  connectivity_subscription_id = "00000000-0000-0000-0000-000000000002"
  identity_subscription_id     = "00000000-0000-0000-0000-000000000003"
}
```

### Complete Example

```hcl
module "alz" {
  source = "./modules/ALZ"

  # Required
  location = "westeurope"

  # Architecture  
  architecture_name = "prod"

  # Platform subscriptions
  management_subscription_id   = var.management_subscription_id
  connectivity_subscription_id = var.connectivity_subscription_id
  identity_subscription_id     = var.identity_subscription_id
  security_subscription_id     = var.security_subscription_id

  # Additional subscriptions
  additional_subscription_placement = {
    sub-apimanager = {
      subscription_id       = var.apimanager_subscription_id
      management_group_name = "mg-corp"
    }
  }

  # Policy default values
  policy_default_values = {
    amba_alz_management_subscription_id            = var.management_subscription_id
    amba_alz_resource_group_location               = "westeurope"
    amba_alz_resource_group_name                   = "rg-amba-prod-weu"
    amba_alz_byo_user_assigned_managed_identity_id = module.management.user_assigned_identity_id
    amba_alz_action_group_email                    = jsonencode({ value = ["platform@company.com"] })
    log_analytics_workspace_id                     = module.management.log_analytics_workspace_id
    private_dns_zone_subscription_id               = var.connectivity_subscription_id
    private_dns_zone_resource_group_name           = "rg-con-prod-weu-private-dns"
  }

  # Policy modifications
  policy_assignments_to_modify = {
    mg-lzr = {
      policy_assignments = {
        Deploy-AMBA-Notification = {
          parameters = {
            ALZAlertSeverity = jsonencode({ value = var.alert_severity })
          }
        }
        Deploy-MDFC-Config-H224 = {
          parameters = {
            emailSecurityContact = jsonencode({ value = var.security_email })
          }
        }
      }
    }
    mg-plat = {
      policy_assignments = {
        Enable-DDoS-VNET = {
          parameters = {
            ddosPlan = jsonencode({ value = module.ddos.resource_id })
          }
        }
      }
    }
  }

  tags = {
    Environment = "Production"
    Project     = "Azure-Landing-Zone"
  }
}
```

---

## 📁 Library Structure

The `lib/` folder contains custom configurations:

```
lib/
├── alz_library_metadata.json           # Library metadata & dependencies
├── architecture_definitions/
│   └── prod.alz_architecture_definition.json   # MG hierarchy definition
└── archetype_overrides/
    ├── landing_zones_override.alz_archetype_override.yaml
    ├── platform_override.alz_archetype_override.yaml
    └── connectivity_override.alz_archetype_override.yaml
```

### Archetype Overrides

Modify default ALZ archetypes:

**landing_zones_override.yaml** - Removes policies from Landing Zones:
```yaml
name: "landing_zones_override"
base_archetype: "landing_zones"
policy_assignments_to_remove:
  - "Deny-Priv-Esc-AKS"
  - "Enable-DDoS-VNET"
```

**platform_override.yaml** - Adds DDoS at Platform level:
```yaml
name: "platform_override"
base_archetype: "platform"
policy_assignments_to_add: 
  - "Enable-DDoS-VNET"
```

**connectivity_override.yaml** - Removes DDoS from Connectivity:
```yaml
name: "connectivity_override"
base_archetype: "connectivity"
policy_assignments_to_remove:
  - "Enable-DDoS-VNET"
```

---

## 📝 Variables

### Required Variables

| Name       | Type     | Description           |
| ---------- | -------- | --------------------- |
| `location` | `string` | Primary Azure region  |

### Architecture Variables

| Name                 | Type     | Default  | Description                    |
| -------------------- | -------- | -------- | ------------------------------ |
| `architecture_name`  | `string` | `"prod"` | Architecture definition name   |
| `parent_resource_id` | `string` | `null`   | Parent MG (default: tenant)    |

### Subscription Variables

| Name                                | Type          | Default | Description                |
| ----------------------------------- | ------------- | ------- | -------------------------- |
| `management_subscription_id`        | `string`      | `null`  | Management subscription    |
| `connectivity_subscription_id`      | `string`      | `null`  | Connectivity subscription  |
| `identity_subscription_id`          | `string`      | `null`  | Identity subscription      |
| `security_subscription_id`          | `string`      | `null`  | Security subscription      |
| `additional_subscription_placement` | `map(object)` | `{}`    | Additional subscriptions   |

### Policy Variables

| Name                           | Type          | Default | Description              |
| ------------------------------ | ------------- | ------- | ------------------------ |
| `policy_default_values`        | `map(string)` | `{}`    | Default policy values    |
| `policy_assignments_to_modify` | `map(object)` | `{}`    | Policy modifications     |

---

## 📤 Outputs

### Management Groups

```hcl
output "management_group_resource_ids"    # All MG resource IDs
output "root_management_group_id"         # mg-lzr
output "landing_zones_management_group_id" # mg-lz
output "platform_management_group_id"      # mg-plat
output "management_management_group_id"    # mg-mgmt
output "connectivity_management_group_id"  # mg-con
output "identity_management_group_id"      # mg-idt
output "security_management_group_id"      # mg-sec
output "corp_management_group_id"          # mg-corp
output "online_management_group_id"        # mg-online
```

### Policies

```hcl
output "policy_assignment_resource_ids"
output "policy_assignment_identity_ids"
output "policy_definition_resource_ids"
output "policy_set_definition_resource_ids"
```

### Summary

```hcl
output "alz_summary" {
  # architecture_name
  # location
  # management_groups.count
  # subscriptions_placed.count
  # policies.assignments_count
}
```

---

## 📚 Examples

### Example 1: Minimal Deployment

```hcl
module "alz" {
  source = "./modules/ALZ"

  location          = "westeurope"
  architecture_name = "prod"
}
```

### Example 2: With AMBA Integration

```hcl
module "alz" {
  source = "./modules/ALZ"

  location = "westeurope"

  management_subscription_id   = var.management_sub
  connectivity_subscription_id = var.connectivity_sub

  policy_default_values = {
    amba_alz_management_subscription_id = var.management_sub
    amba_alz_resource_group_name        = "rg-amba-prod"
    amba_alz_action_group_email         = jsonencode({ value = ["alerts@company.com"] })
    log_analytics_workspace_id          = azurerm_log_analytics_workspace.main.id
  }
}
```

---

## 🐛 Troubleshooting

### "Management group not found"

Delete the ALZ provider cache:
```bash
rm -rf .alzlib/
terraform init
```

### "Policy definition not found"

Increase retry configuration:
```hcl
retries = {
  policy_assignments = {
    interval_seconds     = 30
    max_interval_seconds = 120
  }
}
```

### "AuthorizationFailed"

Ensure you have Owner/Global Administrator permissions at tenant root.

---

## ⚠️ Important Notes

1. **`.alzlib/` directory** - Auto-generated cache, add to `.gitignore`
2. **Policy parameters** - Use `jsonencode({ value = "..." })` format
3. **Library order** - Later libraries override earlier ones
4. **Subscription placement** - Subscriptions must exist before placement

---

## 📄 License

MIT License

## 👥 Authors

**Neko-IT-Org**
