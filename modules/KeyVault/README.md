# 🔐 Azure Key Vault Terraform Module

Terraform module to deploy a **secure Azure Key Vault** with support for **Private Endpoint**, **Network ACLs**, **RBAC**, and **telemetry**.

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Usage](#-usage)
- [Variables](#-variables)
- [Outputs](#-outputs)
- [Examples](#-examples)
- [Security](#-security)
- [Best Practices](#-best-practices)
- [Troubleshooting](#-troubleshooting)

---

## 🎯 Overview

This module deploys a **production-ready Azure Key Vault** including:

- ✅ **Private Endpoint** with private DNS
- ✅ **Network ACLs** for network access control
- ✅ **RBAC** (Role-Based Access Control)
- ✅ **Soft Delete** with purge protection
- ✅ **Telemetry** to Log Analytics
- ✅ **Encryption** for disks, deployments, ARM templates
- ✅ **Automatic tagging** with creation timestamp

---

## 🏛️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure Key Vault                          │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ SKU: Standard / Premium (HSM-backed)                 │  │
│  │ • Secrets, Keys, Certificates                        │  │
│  │ • Soft Delete: 7-90 days retention                   │  │
│  │ • Purge Protection: Enabled                          │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ RBAC Authorization                                   │  │
│  │ • Key Vault Administrator (auto-assigned)            │  │
│  │ • Key Vault Secrets User                             │  │
│  │ • Key Vault Crypto Officer                           │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Network Security                                     │  │
│  │ • Public Access: Disabled                            │  │
│  │ • Network ACLs: Deny by default                      │  │
│  │ • Allowed IPs/Subnets: Configurable                  │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      │ Private Link
                      ▼
          ┌───────────────────────┐
          │   Private Endpoint    │
          │ • Private IP: 10.x.x.x│
          │ • Subnet: Private     │
          │ • DNS: privatelink.   │
          │   vaultcore.azure.net │
          └───────────────────────┘
                      │
                      ▼
          ┌───────────────────────┐
          │  Private DNS Zone     │
          │ Auto-registration     │
          │ • kv-name.vault.net → │
          │   10.x.x.x            │
          └───────────────────────┘
```

### Connection Flow

1. **Application** → Resolves `kv-name.vault.azure.net` via Private DNS
2. **Private DNS** → Returns private IP `10.x.x.x`
3. **Application** → Connects via Private Endpoint (no public traffic)
4. **Key Vault** → Authentication via Azure AD (RBAC)
5. **Key Vault** → Returns secrets/keys securely

---

## ✨ Features

### Network Security

- 🔒 **Private Endpoint** - Private access without Internet exposure
- 🔒 **Network ACLs** - IP/Subnet filtering with whitelist
- 🔒 **Bypass Azure Services** - Allow trusted Azure services
- 🔒 **Static Private IP** (optional) - For advanced configurations

### Access Management

- 🔑 **Azure native RBAC** - Role-based access control
- 🔑 **Automatic assignment** - Admin role for current user
- 🔑 **Tenant ID validation** - GUID format verified

### Data Protection

- 🛡️ **Soft Delete** - 7-90 days retention (recovery possible)
- 🛡️ **Purge Protection** - Prevents permanent deletion
- 🛡️ **Disk Encryption** - Support for Azure Disk Encryption
- 🛡️ **VM Deployment** - Support for VM deployments
- 🛡️ **ARM Templates** - Support for Azure Resource Manager templates

### Observability

- 📊 **Diagnostic Settings** - Logs and metrics to Log Analytics
- 📊 **Audit Events** - All secret/key access recorded
- 📊 **Policy Evaluation** - Azure Policy compliance logs
- 📊 **Metrics** - Availability, latency, usage

---

## 📦 Prerequisites

### Required Tools

| Tool       | Version | Description                |
| ---------- | ------- | -------------------------- |
| Terraform  | ≥ 1.5.0 | Infrastructure provisioning|
| Azure CLI  | ≥ 2.50  | Azure authentication       |

### Azure Permissions

- **Subscription Contributor** or equivalent permissions
- **Key Vault Permissions**:
  - `Microsoft.KeyVault/vaults/write`
  - `Microsoft.Authorization/roleAssignments/write`
  - `Microsoft.Network/privateEndpoints/write`

### Existing Resources

- ✅ **Resource Group** existing
- ✅ **Virtual Network** with subnet for Private Endpoint
- ✅ **Private DNS Zone** (optional): `privatelink.vaultcore.azure.net`
- ✅ **Log Analytics Workspace** (optional): For telemetry

---

## 🚀 Usage

### Basic Usage

```hcl
module "keyvault" {
  source = "./modules/KeyVault"

  # Basic configuration
  name                = "kv-myapp-prod-weu-01"
  location            = "westeurope"
  resource_group_name = "rg-security-prod-weu-01"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  # SKU
  sku_name = "standard"  # or "premium" for HSM

  # RBAC
  enable_rbac                 = true
  assign_rbac_to_current_user = true

  # Security
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = false
  enabled_for_template_deployment = false
  soft_delete_retention_days      = 90
  purge_protection_enabled        = true
  public_network_access_enabled   = false

  # Private Endpoint
  subnet_id = azurerm_subnet.private_endpoints.id

  tags = {
    Environment = "Production"
    CostCenter  = "Security"
    Compliance  = "ISO27001"
  }
}
```

### With Network ACLs

```hcl
module "keyvault_secured" {
  source = "./modules/KeyVault"

  name                = "kv-secured-prod-weu-01"
  location            = "westeurope"
  resource_group_name = "rg-security-prod-weu-01"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name    = "premium"  # HSM-backed
  enable_rbac = true

  # Strict network configuration
  public_network_access_enabled = false

  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = [
      "203.0.113.10",      # Admin IP 1
      "203.0.113.20"       # Admin IP 2
    ]
    subnet_ids = [
      azurerm_subnet.management.id,
      azurerm_subnet.devops.id
    ]
  }

  # Private Endpoint
  subnet_id          = azurerm_subnet.private_endpoints.id
  private_ip_address = "10.0.10.50"  # Static IP

  tags = {
    Environment = "Production"
    Criticality = "High"
  }
}
```

### With Private DNS Zone

```hcl
# Private DNS Zone (create once)
resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = "rg-dns-prod-weu-01"
}

# DNS Link <-> VNet
resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                  = "link-keyvault-dns"
  resource_group_name   = azurerm_private_dns_zone.keyvault.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = azurerm_virtual_network.main.id
}

# Key Vault with automatic DNS
module "keyvault_with_dns" {
  source = "./modules/KeyVault"

  name                = "kv-app-prod-weu-01"
  location            = "westeurope"
  resource_group_name = "rg-app-prod-weu-01"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                      = "standard"
  enable_rbac                   = true
  public_network_access_enabled = false
  subnet_id                     = azurerm_subnet.private_endpoints.id

  # Automatic DNS integration
  private_dns_zone_group = {
    private_dns_zone_ids = [
      azurerm_private_dns_zone.keyvault.id
    ]
  }

  tags = {
    Environment = "Production"
  }
}
```

### With Full Telemetry

```hcl
# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-monitoring-prod-weu-01"
  location            = "westeurope"
  resource_group_name = "rg-monitoring-prod-weu-01"
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

# Key Vault with monitoring
module "keyvault_monitored" {
  source = "./modules/KeyVault"

  name                = "kv-monitored-prod-weu-01"
  location            = "westeurope"
  resource_group_name = "rg-app-prod-weu-01"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                      = "premium"
  enable_rbac                   = true
  public_network_access_enabled = false
  subnet_id                     = azurerm_subnet.private_endpoints.id

  # Telemetry enabled
  enable_telemetry = true
  telemetry_settings = {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
    
    # Log categories
    log_categories = [
      "AuditEvent",                   # All access events
      "AzurePolicyEvaluationDetails"  # Compliance
    ]
    
    # Metrics
    metric_categories = ["AllMetrics"]
  }

  tags = {
    Environment = "Production"
    Monitoring  = "Enabled"
  }
}
```

---

## 📝 Variables

### Required Variables

| Name                    | Type     | Description                                    |
| ----------------------- | -------- | ---------------------------------------------- |
| `name`                  | `string` | Key Vault name (3-24 characters)               |
| `location`              | `string` | Azure region (e.g., `westeurope`)              |
| `resource_group_name`   | `string` | Existing Resource Group name                   |
| `subnet_id`             | `string` | Subnet ID for Private Endpoint                 |

### Configuration Variables

| Name                              | Type     | Default     | Description                                 |
| --------------------------------- | -------- | ----------- | ------------------------------------------- |
| `tenant_id`                       | `string` | `null`      | Azure AD Tenant ID (GUID validated)         |
| `sku_name`                        | `string` | `"premium"` | SKU: `standard` or `premium` (HSM)          |
| `enable_rbac`                     | `bool`   | `true`      | Enable RBAC (recommended)                   |
| `assign_rbac_to_current_user`     | `bool`   | `true`      | Auto-assign Admin role                      |
| `enabled_for_disk_encryption`     | `bool`   | `false`     | Support Azure Disk Encryption               |
| `enabled_for_deployment`          | `bool`   | `false`     | Support VM deployments                      |
| `enabled_for_template_deployment` | `bool`   | `false`     | Support ARM templates                       |
| `soft_delete_retention_days`      | `number` | `90`        | Soft delete retention (7-90 days)           |
| `purge_protection_enabled`        | `bool`   | `true`      | Purge protection (recommended for prod)     |
| `public_network_access_enabled`   | `bool`   | `false`     | Public access (disable in prod)             |
| `private_ip_address`              | `string` | `null`      | Static IP for Private Endpoint              |

### Network ACLs Variables

| Name           | Type     | Default | Description                               |
| -------------- | -------- | ------- | ----------------------------------------- |
| `network_acls` | `object` | `null`  | Network firewall configuration            |

**`network_acls` Structure**:
```hcl
network_acls = {
  default_action = "Deny"              # "Allow" or "Deny"
  bypass         = "AzureServices"     # "AzureServices" or "None"
  ip_rules       = ["1.2.3.4/32"]      # List of public IPs
  subnet_ids     = [subnet.id]         # List of subnet IDs
}
```

### DNS and Telemetry Variables

| Name                      | Type     | Default | Description                            |
| ------------------------- | -------- | ------- | -------------------------------------- |
| `private_dns_zone_group`  | `object` | `null`  | Private DNS configuration              |
| `enable_telemetry`        | `bool`   | `false` | Enable diagnostic settings             |
| `telemetry_settings`      | `object` | `null`  | Logs and metrics configuration         |
| `tags`                    | `map`    | `{}`    | Custom tags                            |

**`telemetry_settings` Structure**:
```hcl
telemetry_settings = {
  log_analytics_workspace_id = "/subscriptions/.../workspaces/log-xxx"
  storage_account_id         = null  # Optional
  event_hub_authorization_rule_id = null  # Optional
  event_hub_name             = null  # Optional
  
  log_categories = [
    "AuditEvent",
    "AzurePolicyEvaluationDetails"
  ]
  
  metric_categories = ["AllMetrics"]
}
```

---

## 📤 Outputs

| Name                   | Description                                      |
| ---------------------- | ------------------------------------------------ |
| `id`                   | Key Vault resource ID                            |
| `uri`                  | Key Vault URI (`https://kv-xxx.vault.azure.net/`)|
| `name`                 | Key Vault name                                   |
| `location`             | Azure region                                     |
| `resource_group_name`  | Resource group name                              |
| `private_endpoint_id`  | Private Endpoint resource ID                     |
| `private_endpoint_ip`  | Private Endpoint IP address                      |

### Using Outputs

```hcl
# Reference Key Vault in another module
module "app" {
  source = "./modules/app"
  
  key_vault_id  = module.keyvault.id
  key_vault_uri = module.keyvault.uri
}

# Display Private Endpoint IP
output "keyvault_private_ip" {
  value = module.keyvault.private_endpoint_ip
}
```

---

## 📚 Complete Examples

### Example 1: Simple Dev Key Vault

```hcl
module "kv_dev" {
  source = "./modules/KeyVault"

  name                = "kv-myapp-dev-weu-01"
  location            = "westeurope"
  resource_group_name = "rg-dev-weu-01"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name    = "standard"
  enable_rbac = true

  # Relaxed configuration for dev
  enabled_for_disk_encryption     = false
  enabled_for_deployment          = false
  enabled_for_template_deployment = false
  soft_delete_retention_days      = 7   # Minimum
  purge_protection_enabled        = false
  public_network_access_enabled   = true  # Public access OK in dev

  subnet_id = azurerm_subnet.private.id

  tags = {
    Environment = "Development"
    Owner       = "DevTeam"
  }
}
```

### Example 2: Secured Production Key Vault

```hcl
module "kv_prod" {
  source = "./modules/KeyVault"

  name                = "kv-banking-prod-weu-01"
  location            = "westeurope"
  resource_group_name = "rg-security-prod-weu-01"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  # Premium SKU for HSM
  sku_name    = "premium"
  enable_rbac = true

  # Maximum security
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = false
  enabled_for_template_deployment = false
  soft_delete_retention_days      = 90  # Maximum
  purge_protection_enabled        = true
  public_network_access_enabled   = false

  # Strict Network ACLs
  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = ["203.0.113.50/32"]  # Admin IP only
    subnet_ids     = [
      azurerm_subnet.management.id
    ]
  }

  # Private Endpoint with static IP
  subnet_id          = azurerm_subnet.private_endpoints.id
  private_ip_address = "10.0.10.100"

  # Automatic DNS
  private_dns_zone_group = {
    private_dns_zone_ids = [azurerm_private_dns_zone.keyvault.id]
  }

  # Full telemetry
  enable_telemetry = true
  telemetry_settings = {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.security.id
    storage_account_id         = azurerm_storage_account.audit_logs.id
    
    log_categories = [
      "AuditEvent",
      "AzurePolicyEvaluationDetails"
    ]
    
    metric_categories = ["AllMetrics"]
  }

  tags = {
    Environment = "Production"
    CostCenter  = "Security"
    Compliance  = "PCI-DSS"
    Criticality = "Critical"
  }
}
```

### Example 3: Multi-Environment with Workspaces

```hcl
locals {
  environments = ["dev", "staging", "prod"]
  
  common_config = {
    location            = "westeurope"
    tenant_id           = data.azurerm_client_config.current.tenant_id
    sku_name            = "standard"
    enable_rbac         = true
    subnet_id           = azurerm_subnet.private_endpoints.id
  }
  
  env_specific = {
    dev = {
      soft_delete_retention_days    = 7
      purge_protection_enabled      = false
      public_network_access_enabled = true
    }
    staging = {
      soft_delete_retention_days    = 30
      purge_protection_enabled      = false
      public_network_access_enabled = false
    }
    prod = {
      soft_delete_retention_days    = 90
      purge_protection_enabled      = true
      public_network_access_enabled = false
    }
  }
}

module "keyvault" {
  for_each = toset(local.environments)
  
  source = "./modules/KeyVault"

  name                = "kv-myapp-${each.key}-weu-01"
  location            = local.common_config.location
  resource_group_name = "rg-${each.key}-weu-01"
  tenant_id           = local.common_config.tenant_id
  sku_name            = local.common_config.sku_name
  enable_rbac         = local.common_config.enable_rbac
  subnet_id           = local.common_config.subnet_id

  # Environment-specific configuration
  soft_delete_retention_days    = local.env_specific[each.key].soft_delete_retention_days
  purge_protection_enabled      = local.env_specific[each.key].purge_protection_enabled
  public_network_access_enabled = local.env_specific[each.key].public_network_access_enabled

  tags = {
    Environment = title(each.key)
    ManagedBy   = "Terraform"
  }
}
```

---

## 🔒 Security

### Network Security

#### Private Endpoint (Recommended for Production)

**Advantages**:
- ✅ No traffic over public Internet
- ✅ Private IP in your VNet
- ✅ Automatic DNS resolution
- ✅ Compatible with Express Route / VPN

**Configuration**:
```hcl
public_network_access_enabled = false
subnet_id = azurerm_subnet.private_endpoints.id
```

#### Network ACLs

**Principle**: Whitelist of allowed IPs/Subnets

```hcl
network_acls = {
  default_action = "Deny"           # Block everything by default
  bypass         = "AzureServices"  # Except trusted Azure services
  
  ip_rules = [
    "203.0.113.10/32",   # Admin 1
    "203.0.113.20/32"    # Admin 2
  ]
  
  subnet_ids = [
    azurerm_subnet.management.id,
    azurerm_subnet.aks.id
  ]
}
```

**⚠️ Important**: `bypass = "AzureServices"` allows Azure services (Storage, SQL, etc.) to access Key Vault even if `default_action = "Deny"`.

### RBAC (Role-Based Access Control)

#### Built-In Roles

| Role                           | Permissions                                      |
| ------------------------------ | ------------------------------------------------ |
| Key Vault Administrator        | Full management (CRUD keys/secrets/certs)        |
| Key Vault Secrets User         | Read secrets only                                |
| Key Vault Crypto Officer       | Manage cryptographic keys                        |
| Key Vault Crypto User          | Use keys (encrypt/decrypt/sign)                  |
| Key Vault Certificates Officer | Manage certificates                              |

#### Manual Assignment

```hcl
# Assign role to Service Principal
resource "azurerm_role_assignment" "app" {
  scope                = module.keyvault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}
```

### Soft Delete & Purge Protection

**Soft Delete**:
- Retention: 7-90 days
- Allows recovery in case of accidental deletion
- Mandatory since 2021 (cannot be disabled)

**Purge Protection**:
- Prevents permanent deletion during retention period
- **Recommended in production** to avoid data loss
- Once enabled, **cannot be disabled**!

```hcl
soft_delete_retention_days = 90
purge_protection_enabled   = true  # ⚠️ Irreversible!
```

### Encryption Enablement

```hcl
# For Azure Disk Encryption
enabled_for_disk_encryption = true

# For VM deployments (ARM templates)
enabled_for_deployment = true

# For generic ARM templates
enabled_for_template_deployment = true
```

---

## ✅ Best Practices

### Production

1. **Premium SKU**: Use `sku_name = "premium"` for HSM-backed keys
2. **Private Endpoint**: Mandatory (`public_network_access_enabled = false`)
3. **Network ACLs**: `default_action = "Deny"` with strict whitelist
4. **Purge Protection**: `purge_protection_enabled = true`
5. **Soft Delete Max**: `soft_delete_retention_days = 90`
6. **RBAC**: `enable_rbac = true` (more secure than Access Policies)
7. **Telemetry**: `enable_telemetry = true` with Log Analytics
8. **Tags**: Include `Compliance`, `Criticality`, `Owner`

### Development

1. **Standard SKU**: Sufficient for dev/test
2. **Public Access**: OK if accessed from local developer
3. **Soft Delete Min**: `soft_delete_retention_days = 7`
4. **Purge Protection**: `false` to facilitate testing
5. **RBAC**: Enable to test permissions

### Naming Convention

```
kv-<application>-<environment>-<region>-<instance>

Examples:
- kv-banking-prod-weu-01
- kv-webapp-staging-eus-01
- kv-shared-prod-weu-01
```

**⚠️ Constraints**:
- 3-24 characters
- Alphanumerics and hyphens only
- Globally unique (Azure-wide)

### Secret Rotation

```hcl
# Create secret with expiration
resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = random_password.db.result
  key_vault_id = module.keyvault.id
  
  # Expires in 90 days
  expiration_date = timeadd(timestamp(), "2160h")
}

# Notification before expiration (Azure Monitor Alert)
resource "azurerm_monitor_metric_alert" "secret_expiry" {
  name                = "alert-secret-expiring"
  resource_group_name = "rg-monitoring-prod-weu-01"
  scopes              = [module.keyvault.id]
  
  criteria {
    metric_namespace = "Microsoft.KeyVault/vaults"
    metric_name      = "SecretNearExpiry"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 0
  }
}
```

### Backup Strategy

Azure Key Vault is **automatically geo-replicated** within the same region (zone redundancy).

For **disaster recovery**:
1. Export critical keys/secrets to Azure Backup
2. Use Terraform state to recreate configuration
3. Document manual secrets (do not store in Terraform)

---

## 🐛 Troubleshooting

### Error: "Key Vault name already exists"

**Cause**: Globally unique name required

**Solution**:
```bash
# Check availability
az keyvault list --query "[?name=='kv-myapp-prod-weu-01']"

# If recently deleted (soft delete)
az keyvault list-deleted

# Purge (if purge protection disabled)
az keyvault purge --name kv-myapp-prod-weu-01
```

### Error: "Access denied" during creation

**Cause**: Insufficient permissions

**Solution**:
```bash
# Check permissions
az role assignment list --assignee <your-principal-id> \
  --scope /subscriptions/<sub-id>/resourceGroups/<rg-name>

# Assign required role
az role assignment create \
  --assignee <your-principal-id> \
  --role "Key Vault Contributor" \
  --scope /subscriptions/<sub-id>/resourceGroups/<rg-name>
```

### Error: "Cannot access Key Vault from application"

**Diagnostic**:
1. Check that `public_network_access_enabled = false` if Private Endpoint
2. Check Network ACLs (allowed IP/Subnet)
3. Check DNS resolution (`nslookup kv-name.vault.azure.net`)
4. Check application's RBAC permissions

**Solution**:
```bash
# Test connectivity
curl -v https://kv-name.vault.azure.net

# Check Network ACLs
az keyvault network-rule list --name kv-name --resource-group rg-name

# Add IP temporarily
az keyvault network-rule add \
  --name kv-name \
  --resource-group rg-name \
  --ip-address <your-ip>/32
```

### Error: "The subscription is not registered to use namespace 'Microsoft.KeyVault'"

**Solution**:
```bash
az provider register --namespace Microsoft.KeyVault
az provider show --namespace Microsoft.KeyVault --query "registrationState"
```

### Private Endpoint not working

**Checklist**:
- [ ] Private DNS Zone created: `privatelink.vaultcore.azure.net`
- [ ] DNS Zone linked to VNet
- [ ] Private Endpoint in correct subnet
- [ ] Subnet NSG allows outbound traffic to `AzureCloud`
- [ ] `public_network_access_enabled = false`

**DNS Verification**:
```bash
# From a VM in the VNet
nslookup kv-name.vault.azure.net

# Should return private IP (10.x.x.x)
```

---

## 📊 Estimated Costs

### Region: West Europe (monthly estimate)

| Resource                | Quantity | Cost/Month (USD) |
| ----------------------- | -------- | ---------------- |
| Key Vault Standard      | 1        | ~$0 (free)       |
| Key Vault Premium (HSM) | 1        | ~$0 (free)       |
| Secret Operations (10K) | 1        | ~$0.03           |
| Key Operations (10K)    | 1        | ~$0.03           |
| Cert Operations (10K)   | 1        | ~$0.03           |
| Private Endpoint        | 1        | ~$7.30           |
| Private Link (1TB)      | 1        | ~$10             |
| **Total (no HSM)**      |          | **~$17.40**      |
| **Total (with HSM)**    |          | **~$17.40**      |

**Note**: Main costs come from operations and Private Endpoint, not the Key Vault itself.

---

## 📄 Resources

### Official Documentation

- [Azure Key Vault Overview](https://learn.microsoft.com/en-us/azure/key-vault/general/overview)
- [Key Vault Networking](https://learn.microsoft.com/en-us/azure/key-vault/general/network-security)
- [Key Vault RBAC](https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide)
- [Soft Delete & Purge Protection](https://learn.microsoft.com/en-us/azure/key-vault/general/soft-delete-overview)

### Terraform Providers

- [azurerm_key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault)
- [azurerm_private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint)
- [azurerm_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)

---

## 📝 Changelog

### Version 1.0.0
- ✅ Initial release
- ✅ Private Endpoint support
- ✅ Network ACLs support
- ✅ RBAC support
- ✅ Soft Delete & Purge Protection support
- ✅ Telemetry support
- ✅ Complete documentation

---

**⭐ If this module helps you, feel free to share it!**
