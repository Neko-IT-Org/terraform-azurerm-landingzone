# 🔑 Azure Key Vault Key Terraform Module

Terraform module to create and manage **cryptographic keys** in Azure Key Vault with support for **automatic rotation**, **HSM**, and **expiration policies**.

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Features](#-features)
- [Key Types](#-key-types)
- [Usage](#-usage)
- [Variables](#-variables)
- [Outputs](#-outputs)
- [Examples](#-examples)
- [Rotation Policies](#-rotation-policies)
- [Best Practices](#-best-practices)
- [Troubleshooting](#-troubleshooting)

---

## 🎯 Overview

This module allows you to create and manage **cryptographic keys** in Azure Key Vault for:

- ✅ **Encryption at Rest** - Data encryption (CMK for Storage, SQL, Cosmos DB)
- ✅ **Digital Signatures** - Signing tokens, certificates, documents
- ✅ **Key Wrapping** - Protection of symmetric keys (DEK wrapping)
- ✅ **HSM-backed Keys** - Keys stored in FIPS 140-2 Level 2 HSMs
- ✅ **Automatic Rotation** - Automatic key rotation
- ✅ **Expiration Policies** - Validity dates and notifications

---

## 🏛️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure Key Vault                          │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Key: encryption-key-v1                               │  │
│  │ • Type: RSA 4096                                     │  │
│  │ • Created: 2024-01-27                                │  │
│  │ • Expires: 2026-01-27 (2 years)                      │  │
│  │ • Operations: encrypt, decrypt, wrapKey, unwrapKey   │  │
│  │ • HSM-backed: Yes                                    │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Rotation Policy                                      │  │
│  │ • Expire After: P2Y (2 years)                        │  │
│  │ • Notify Before: P30D (30 days)                      │  │
│  │ • Auto-Rotate: P1Y (1 year after creation)           │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Timeline                                             │  │
│  │ T0: Key created                                      │  │
│  │ T0+1Y: Auto-rotation → new version created           │  │
│  │ T0+1Y+11M: Notification (30 days before expiry)      │  │
│  │ T0+2Y: Key expires                                   │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                      │
                      │ Used by
                      ▼
          ┌───────────────────────┐
          │   Azure Services      │
          │ • Storage Account CMK │
          │ • SQL TDE             │
          │ • Cosmos DB           │
          │ • Disk Encryption     │
          └───────────────────────┘
```

### Usage Flow

1. **Application** → Requests an operation (encrypt/decrypt/sign)
2. **Azure AD** → Verifies RBAC permissions
3. **Key Vault** → Checks key validity (not_before_date, expiration_date)
4. **HSM** (if Premium) → Performs cryptographic operation
5. **Key Vault** → Returns encrypted result
6. **Audit Log** → Records operation in Azure Monitor

---

## ✨ Features

### Supported Key Types

- 🔐 **RSA** - 2048, 3072, 4096 bits (standard and HSM)
- 🔐 **EC** (Elliptic Curve) - P-256, P-384, P-521, P-256K
- 🔐 **HSM-backed** - FIPS 140-2 Level 2 hardware protection

### Cryptographic Operations

- 🔒 **encrypt / decrypt** - Data encryption
- ✍️ **sign / verify** - Digital signatures
- 🔄 **wrapKey / unwrapKey** - Key wrapping (DEK wrapping)

### Lifecycle Management

- ⏰ **Automatic expiration** - Default: +2 years
- 🔔 **Notifications** - Alerts before expiration
- 🔄 **Automatic rotation** - Configurable policy
- 📅 **Validity periods** - not_before_date, expiration_date

### Security & Compliance

- 🛡️ **HSM FIPS 140-2 Level 2** - For Premium keys
- 🛡️ **Audit logs** - All operations traced
- 🛡️ **RBAC** - Granular access control
- 🛡️ **Key versioning** - Version history

---

## 🔑 Key Types

### RSA Keys

**Usage**: Asymmetric encryption, signatures

| Size | Security | Performance | Usage                              |
| ---- | -------- | ----------- | ---------------------------------- |
| 2048 | Standard | Fast        | Dev/Test, light encryption         |
| 3072 | High     | Medium      | General production                 |
| 4096 | Maximum  | Slow        | Sensitive data, long-term          |

**Example**:
```hcl
keys = {
  encryption_key = {
    name         = "rsa-encryption-key"
    key_type     = "RSA"
    key_size     = 4096
    key_vault_id = azurerm_key_vault.main.id
    key_opts     = ["encrypt", "decrypt", "wrapKey", "unwrapKey"]
  }
}
```

### EC Keys (Elliptic Curve)

**Usage**: Signatures, authentication (JWT, SSL/TLS)

| Curve   | RSA Equivalent | Performance  | Usage                          |
| ------- | -------------- | ------------ | ------------------------------ |
| P-256   | RSA 3072       | Very fast    | JWT tokens, TLS                |
| P-384   | RSA 7680       | Fast         | High-security signatures       |
| P-521   | RSA 15360      | Medium       | Long-term signatures           |
| P-256K  | RSA 3072       | Very fast    | Bitcoin, blockchain            |

**Example**:
```hcl
keys = {
  signing_key = {
    name         = "ec-signing-key"
    key_type     = "EC"
    curve        = "P-384"
    key_vault_id = azurerm_key_vault.main.id
    key_opts     = ["sign", "verify"]
  }
}
```

### HSM-backed Keys

**Usage**: Critical data, FIPS compliance

**Advantages**:
- ✅ Keys stored in hardware HSM (FIPS 140-2 Level 2)
- ✅ Non-exportable keys
- ✅ Regulatory compliance (PCI-DSS, HIPAA)
- ✅ Protection against physical extraction

**Prerequisites**:
- Key Vault Premium SKU

**Example**:
```hcl
keys = {
  hsm_key = {
    name         = "hsm-master-key"
    key_type     = "RSA-HSM"
    key_size     = 4096
    key_vault_id = azurerm_key_vault.premium.id
    key_opts     = ["encrypt", "decrypt", "wrapKey", "unwrapKey"]
  }
}
```

---

## 🚀 Usage

### Basic Usage

```hcl
module "keyvault_keys" {
  source = "./modules/KeyVault-Key"

  keys = {
    # RSA key for encryption
    storage_encryption = {
      name         = "storage-cmk"
      key_type     = "RSA"
      key_size     = 4096
      key_vault_id = azurerm_key_vault.main.id
      key_opts     = ["encrypt", "decrypt", "wrapKey", "unwrapKey"]
      
      tags = {
        Purpose = "Storage Account CMK"
      }
    }
    
    # EC key for signatures
    jwt_signing = {
      name         = "jwt-signing-key"
      key_type     = "EC"
      curve        = "P-256"
      key_vault_id = azurerm_key_vault.main.id
      key_opts     = ["sign", "verify"]
      
      tags = {
        Purpose = "JWT Token Signing"
      }
    }
  }

  # Global tags
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### With Custom Validity Dates

```hcl
module "keyvault_keys_custom" {
  source = "./modules/KeyVault-Key"

  keys = {
    temp_key = {
      name         = "temporary-encryption-key"
      key_type     = "RSA"
      key_size     = 2048
      key_vault_id = azurerm_key_vault.main.id
      
      # Valid from January 1, 2026
      not_before_date = "2026-01-01T00:00:00Z"
      
      # Expires December 31, 2026
      expiration_date = "2026-12-31T23:59:59Z"
      
      key_opts = ["encrypt", "decrypt"]
    }
  }
}
```

### With Automatic Rotation

```hcl
module "keyvault_keys_rotated" {
  source = "./modules/KeyVault-Key"

  keys = {
    auto_rotated_key = {
      name         = "auto-rotation-key"
      key_type     = "RSA"
      key_size     = 4096
      key_vault_id = azurerm_key_vault.main.id
      key_opts     = ["encrypt", "decrypt", "wrapKey", "unwrapKey"]
      
      # Rotation policy
      rotation_policy = {
        # Expires after 2 years
        expire_after = "P2Y"
        
        # Notify 30 days before expiration
        notify_before_expiry = "P30D"
        
        # Automatic rotation
        automatic = {
          # Create new version 1 year after creation
          time_after_creation = "P1Y"
        }
      }
      
      tags = {
        AutoRotation = "Enabled"
      }
    }
  }
}
```

### HSM-backed Keys

```hcl
module "keyvault_hsm_keys" {
  source = "./modules/KeyVault-Key"

  keys = {
    # Master HSM Key
    master_key = {
      name         = "master-encryption-key"
      key_type     = "RSA-HSM"  # HSM-backed
      key_size     = 4096
      key_vault_id = azurerm_key_vault.premium.id  # Premium SKU required
      key_opts     = ["encrypt", "decrypt", "wrapKey", "unwrapKey"]
      
      rotation_policy = {
        expire_after         = "P5Y"   # 5 years for master keys
        notify_before_expiry = "P90D"  # Notify 90 days before
        automatic = {
          time_after_creation = "P2Y"  # Rotate every 2 years
        }
      }
      
      tags = {
        Criticality = "Critical"
        Compliance  = "FIPS-140-2"
      }
    }
    
    # HSM Signing Key
    signing_key = {
      name         = "hsm-signing-key"
      key_type     = "EC-HSM"
      curve        = "P-384"
      key_vault_id = azurerm_key_vault.premium.id
      key_opts     = ["sign", "verify"]
      
      tags = {
        Purpose = "Code Signing"
      }
    }
  }

  tags = {
    Environment = "Production"
    HSM         = "Enabled"
  }
}
```

---

## 📝 Variables

### Variable `keys`

**Type**: `map(object)` (required)

**Structure**:
```hcl
keys = {
  <key_name> = {
    name            = string           # Key name (required)
    key_type        = string           # RSA, EC, RSA-HSM, EC-HSM (required)
    key_vault_id    = string           # Key Vault ID (required)
    key_size        = number           # 2048, 3072, 4096 (for RSA)
    curve           = string           # P-256, P-384, P-521, P-256K (for EC)
    key_opts        = list(string)     # Allowed operations
    not_before_date = string           # ISO 8601 format
    expiration_date = string           # ISO 8601 format
    tags            = map(string)      # Key-specific tags
    rotation_policy = object({...})    # Rotation policy
  }
}
```

### Key Attributes

| Attribute         | Type          | Required | Default                                                   | Description                          |
| ----------------- | ------------- | -------- | --------------------------------------------------------- | ------------------------------------ |
| `name`            | `string`      | ✅       | -                                                         | Key name                             |
| `key_type`        | `string`      | ✅       | -                                                         | RSA, EC, RSA-HSM, EC-HSM             |
| `key_vault_id`    | `string`      | ✅       | -                                                         | Full Key Vault ID                    |
| `key_size`        | `number`      | ❌       | -                                                         | 2048, 3072, 4096 (required for RSA)  |
| `curve`           | `string`      | ❌       | -                                                         | P-256, P-384, P-521, P-256K (for EC) |
| `key_opts`        | `list(string)`| ❌       | `["encrypt","decrypt","wrapKey","unwrapKey","sign","verify"]` | Allowed operations       |
| `not_before_date` | `string`      | ❌       | `null`                                                    | Start validity date (ISO 8601)       |
| `expiration_date` | `string`      | ❌       | `T0 + 2 years`                                            | Expiration date (ISO 8601)           |
| `tags`            | `map(string)` | ❌       | `{}`                                                      | Specific tags                        |
| `rotation_policy` | `object`      | ❌       | `null`                                                    | Rotation policy                      |

### Key Operations (`key_opts`)

| Operation   | Usage                                              |
| ----------- | -------------------------------------------------- |
| `encrypt`   | Encrypt data                                       |
| `decrypt`   | Decrypt data                                       |
| `sign`      | Sign data (digital signature)                      |
| `verify`    | Verify signature                                   |
| `wrapKey`   | Wrap symmetric key (DEK wrapping)                  |
| `unwrapKey` | Unwrap symmetric key                               |

### Rotation Policy Structure

```hcl
rotation_policy = {
  expire_after         = string  # ISO 8601 duration (e.g., "P2Y")
  notify_before_expiry = string  # ISO 8601 duration (e.g., "P30D")
  
  automatic = {
    time_after_creation = string  # ISO 8601 duration (e.g., "P1Y")
    time_before_expiry  = string  # ISO 8601 duration (e.g., "P30D")
  }
}
```

**ISO 8601 Duration Format**:
- `P1Y` = 1 year
- `P6M` = 6 months
- `P30D` = 30 days
- `P1Y6M` = 1 year and 6 months

### Variable `tags`

**Type**: `map(string)` (optional)  
**Default**: `{}`

Global tags applied to all keys (merged with specific tags).

---

## 📤 Outputs

| Name               | Type          | Description                                      |
| ------------------ | ------------- | ------------------------------------------------ |
| `keys`             | `map(object)` | Full resources of all keys                       |
| `ids`              | `map(string)` | Versioned IDs (with version)                     |
| `versionless_ids`  | `map(string)` | IDs without version (for auto-rotation)          |
| `names`            | `map(string)` | Key names                                        |
| `key_types`        | `map(string)` | Key types (RSA, EC, etc.)                        |
| `expiration_dates` | `map(string)` | Expiration dates                                 |

### Using Outputs

```hcl
# Versioned ID (fixed version)
output "storage_key_id" {
  value = module.keyvault_keys.ids["storage_encryption"]
}
# Result: https://kv-name.vault.azure.net/keys/storage-cmk/abc123def456

# Versionless ID (always latest version)
output "storage_key_versionless" {
  value = module.keyvault_keys.versionless_ids["storage_encryption"]
}
# Result: https://kv-name.vault.azure.net/keys/storage-cmk

# Use with Storage Account CMK
resource "azurerm_storage_account" "main" {
  name = "stmyappprodweu01"
  # ...
  
  identity {
    type = "SystemAssigned"
  }
  
  customer_managed_key {
    # Use versionless_id for auto-rotation
    key_vault_key_id = module.keyvault_keys.versionless_ids["storage_encryption"]
  }
}
```

---

## 📚 Complete Examples

### Example 1: Keys for Storage Account CMK

```hcl
# Premium Key Vault (for HSM)
resource "azurerm_key_vault" "storage" {
  name                = "kv-storage-prod-weu-01"
  location            = "westeurope"
  resource_group_name = "rg-storage-prod-weu-01"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"  # HSM required for CMK
  
  enable_rbac_authorization = true
  purge_protection_enabled  = true
}

# CMK Keys
module "storage_keys" {
  source = "./modules/KeyVault-Key"

  keys = {
    storage_master_key = {
      name         = "storage-cmk-master"
      key_type     = "RSA-HSM"
      key_size     = 4096
      key_vault_id = azurerm_key_vault.storage.id
      key_opts     = ["encrypt", "decrypt", "wrapKey", "unwrapKey"]
      
      rotation_policy = {
        expire_after         = "P3Y"
        notify_before_expiry = "P90D"
        automatic = {
          time_after_creation = "P1Y"
        }
      }
      
      tags = {
        Purpose     = "Storage Account CMK"
        Criticality = "Critical"
      }
    }
  }

  tags = {
    Environment = "Production"
    Compliance  = "FIPS-140-2"
  }
}

# Storage Account with CMK
resource "azurerm_storage_account" "encrypted" {
  name                     = "stencryptedprodweu01"
  resource_group_name      = "rg-storage-prod-weu-01"
  location                 = "westeurope"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  
  identity {
    type = "SystemAssigned"
  }
  
  customer_managed_key {
    key_vault_key_id = module.storage_keys.versionless_ids["storage_master_key"]
  }
}

# RBAC: Allow Storage to use key
resource "azurerm_role_assignment" "storage_crypto" {
  scope                = azurerm_key_vault.storage.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_storage_account.encrypted.identity[0].principal_id
}
```

### Example 2: Keys for SQL TDE (Transparent Data Encryption)

```hcl
module "sql_keys" {
  source = "./modules/KeyVault-Key"

  keys = {
    sql_tde_key = {
      name         = "sql-tde-key"
      key_type     = "RSA"
      key_size     = 3072
      key_vault_id = azurerm_key_vault.main.id
      key_opts     = ["wrapKey", "unwrapKey"]
      
      rotation_policy = {
        expire_after         = "P2Y"
        notify_before_expiry = "P60D"
        automatic = {
          time_after_creation = "P1Y"
        }
      }
      
      tags = {
        Purpose  = "SQL TDE"
        Database = "production-db"
      }
    }
  }
}

# SQL Server with TDE
resource "azurerm_mssql_server" "main" {
  name                = "sql-myapp-prod-weu-01"
  resource_group_name = "rg-database-prod-weu-01"
  location            = "westeurope"
  version             = "12.0"
  
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.sql.result
  
  identity {
    type = "SystemAssigned"
  }
}

# TDE with CMK
resource "azurerm_mssql_server_transparent_data_encryption" "main" {
  server_id        = azurerm_mssql_server.main.id
  key_vault_key_id = module.sql_keys.versionless_ids["sql_tde_key"]
}
```

### Example 3: JWT Signing Keys

```hcl
module "jwt_keys" {
  source = "./modules/KeyVault-Key"

  keys = {
    jwt_signing_key = {
      name         = "jwt-signing-key"
      key_type     = "EC"
      curve        = "P-256"
      key_vault_id = azurerm_key_vault.main.id
      key_opts     = ["sign", "verify"]
      
      # Key valid for 1 year
      expiration_date = timeadd(timestamp(), "8760h")
      
      rotation_policy = {
        expire_after         = "P1Y"
        notify_before_expiry = "P30D"
        automatic = {
          time_after_creation = "P6M"  # Rotate every 6 months
        }
      }
      
      tags = {
        Purpose  = "JWT Token Signing"
        Audience = "api.example.com"
      }
    }
  }
}
```

### Example 4: Multi-Environment with Rotation

```hcl
locals {
  environments = {
    dev = {
      key_size       = 2048
      rotation_years = 1
      expiry_years   = 2
      notify_days    = 30
    }
    prod = {
      key_size       = 4096
      rotation_years = 1
      expiry_years   = 3
      notify_days    = 90
    }
  }
}

module "keys" {
  for_each = local.environments
  
  source = "./modules/KeyVault-Key"

  keys = {
    encryption_key = {
      name         = "encryption-key-${each.key}"
      key_type     = "RSA"
      key_size     = each.value.key_size
      key_vault_id = azurerm_key_vault.env[each.key].id
      key_opts     = ["encrypt", "decrypt", "wrapKey", "unwrapKey"]
      
      rotation_policy = {
        expire_after         = "P${each.value.expiry_years}Y"
        notify_before_expiry = "P${each.value.notify_days}D"
        automatic = {
          time_after_creation = "P${each.value.rotation_years}Y"
        }
      }
      
      tags = {
        Environment = each.key
      }
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }
}
```

---

## 🔄 Rotation Policies

### Concepts

**Key rotation** = Creating a new version of the key

**Advantages**:
- ✅ Limits exposure in case of compromise
- ✅ Regulatory compliance (PCI-DSS, HIPAA)
- ✅ Cryptographic best practice

### Rotation Types

#### 1. Time-Based Rotation (Time After Creation)

**Principle**: Create new version X time after initial creation

```hcl
rotation_policy = {
  expire_after = "P2Y"  # Expires in 2 years
  
  automatic = {
    time_after_creation = "P1Y"  # Rotate 1 year after creation
  }
}
```

**Timeline**:
```
T0           T0+1Y         T0+2Y
|-------------|-------------|
Create        Rotate        Expire
v1 created    v2 created    v1 expires
```

#### 2. Expiry-Based Rotation (Time Before Expiry)

**Principle**: Create new version X time before expiration

```hcl
rotation_policy = {
  expire_after = "P2Y"
  
  automatic = {
    time_before_expiry = "P30D"  # Rotate 30 days before expiry
  }
}
```

**Timeline**:
```
T0           T0+1Y11M      T0+2Y
|-------------|-------------|
Create        Rotate        Expire
v1 created    v2 created    v1 expires
              (30d before)
```

### Notifications

```hcl
rotation_policy = {
  expire_after         = "P2Y"
  notify_before_expiry = "P30D"  # Notification 30 days before
  
  automatic = {
    time_after_creation = "P1Y"
  }
}
```

**Actions to take**:
1. Configure Azure Monitor Alert for `KeyNearExpiry`
2. Send notification to Ops team
3. Verify services use `versionless_id`

### Policy Examples

#### Short-Lived Keys (Dev/Test)

```hcl
rotation_policy = {
  expire_after         = "P90D"   # 3 months
  notify_before_expiry = "P7D"    # 7 days
  automatic = {
    time_after_creation = "P30D"  # Monthly rotation
  }
}
```

#### Standard Keys (Production)

```hcl
rotation_policy = {
  expire_after         = "P2Y"    # 2 years
  notify_before_expiry = "P30D"   # 30 days
  automatic = {
    time_after_creation = "P1Y"   # Annual rotation
  }
}
```

#### Long-Lived Keys (Master Keys)

```hcl
rotation_policy = {
  expire_after         = "P5Y"    # 5 years
  notify_before_expiry = "P90D"   # 90 days
  automatic = {
    time_after_creation = "P2Y"   # Rotate every 2 years
  }
}
```

---

## ✅ Best Practices

### Production

1. **HSM-backed Keys**: Use `RSA-HSM` or `EC-HSM` for critical data
2. **Key Size**: Minimum 3072 bits for RSA (4096 recommended)
3. **Rotation**: Enable automatic rotation (≤ 2 years)
4. **Expiration**: Set explicit `expiration_date`
5. **Notifications**: `notify_before_expiry` ≥ 30 days
6. **Versionless IDs**: Use `versionless_id` for transparent auto-rotation
7. **RBAC**: Principle of least privilege (Crypto User, not Crypto Officer)
8. **Audit**: Enable diagnostic settings on Key Vault

### Sizing Recommendations

| Use Case            | Key Type  | Size/Curve | Rotation | Expiry  |
| ------------------- | --------- | ---------- | -------- | ------- |
| Storage CMK         | RSA-HSM   | 4096       | 1 year   | 3 years |
| SQL TDE             | RSA       | 3072       | 1 year   | 2 years |
| Disk Encryption     | RSA-HSM   | 4096       | 1 year   | 3 years |
| JWT Signing         | EC        | P-256      | 6 months | 1 year  |
| Code Signing        | EC-HSM    | P-384      | 2 years  | 5 years |
| Document Encryption | RSA       | 2048       | 1 year   | 2 years |

### Naming Convention

```
<purpose>-<type>-<environment>-<region>

Examples:
- storage-cmk-prod-weu
- sql-tde-prod-weu
- jwt-signing-prod-weu
- master-encryption-prod-weu
```

### Versioned vs Versionless IDs

```hcl
# ❌ BAD: Versioned ID (no automatic rotation)
customer_managed_key {
  key_vault_key_id = module.keys.ids["storage_key"]
  # https://kv.vault.azure.net/keys/storage-key/abc123
}

# ✅ GOOD: Versionless ID (transparent rotation)
customer_managed_key {
  key_vault_key_id = module.keys.versionless_ids["storage_key"]
  # https://kv.vault.azure.net/keys/storage-key
}
```

### Tags Best Practices

```hcl
keys = {
  my_key = {
    # ...
    tags = {
      Purpose      = "Storage Account CMK"
      Owner        = "platform-team@company.com"
      CostCenter   = "IT-Infrastructure"
      Compliance   = "PCI-DSS"
      Criticality  = "Critical"
      DataClass    = "Confidential"
      RotationDue  = "2026-01-27"
    }
  }
}
```

---

## 🐛 Troubleshooting

### Error: "Key size is required for RSA keys"

**Cause**: Missing `key_size` for RSA key

**Solution**:
```hcl
keys = {
  my_rsa_key = {
    key_type = "RSA"
    key_size = 4096  # ← Add this
    # ...
  }
}
```

### Error: "Curve is required for EC keys"

**Cause**: Missing `curve` for EC key

**Solution**:
```hcl
keys = {
  my_ec_key = {
    key_type = "EC"
    curve    = "P-256"  # ← Add this
    # ...
  }
}
```

### Error: "Key vault does not have 'premium' SKU"

**Cause**: HSM key on Standard Key Vault

**Solution**:
```hcl
# Change Key Vault to Premium
resource "azurerm_key_vault" "main" {
  sku_name = "premium"  # ← Change from "standard"
  # ...
}
```

### Error: "Access denied" when creating key

**Solution**:
```bash
# Check RBAC permissions
az role assignment list \
  --assignee <principal-id> \
  --scope <key-vault-id>

# Assign required role
az role assignment create \
  --assignee <principal-id> \
  --role "Key Vault Crypto Officer" \
  --scope <key-vault-id>
```

### Automatic rotation not working

**Checklist**:
- [ ] `rotation_policy` configured correctly
- [ ] Valid ISO 8601 format (e.g., `P1Y`, not `1Y`)
- [ ] `expire_after` > `time_after_creation`
- [ ] Sufficient RBAC permissions
- [ ] Key Vault not deleted (soft delete)

### Services not using new version

**Cause**: Services using `id` (versioned) instead of `versionless_id`

**Solution**:
```hcl
# Use versionless_id
customer_managed_key {
  key_vault_key_id = module.keys.versionless_ids["storage_key"]
}
```

---

## 📊 Estimated Costs

### Region: West Europe (monthly estimate)

| Operation                 | Quantity | Unit Cost | Cost/Month (USD) |
| ------------------------- | -------- | --------- | ---------------- |
| Protected Key Operations  | 10,000   | $0.03/10K | $0.03            |
| HSM Protected Operations  | 10,000   | $1.00/10K | $1.00            |
| Key Renewals              | 1        | $0.15     | $0.15            |
| **Total (Standard)**      |          |           | **~$0.18**       |
| **Total (HSM)**           |          |           | **~$1.15**       |

**Note**: Main costs come from HSM operations, not key storage.

---

## 📄 Resources

### Official Documentation

- [Key Vault Keys Overview](https://learn.microsoft.com/en-us/azure/key-vault/keys/about-keys)
- [Key Rotation](https://learn.microsoft.com/en-us/azure/key-vault/keys/how-to-configure-key-rotation)
- [Customer-Managed Keys](https://learn.microsoft.com/en-us/azure/storage/common/customer-managed-keys-overview)

### Terraform Providers

- [azurerm_key_vault_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key)

---

## 📝 Changelog

### Version 1.0.0
- ✅ Initial release
- ✅ RSA, EC, HSM keys support
- ✅ Automatic rotation policies
- ✅ Expiration management
- ✅ Complete documentation

---

**⭐ If this module helps you, feel free to share it!**
