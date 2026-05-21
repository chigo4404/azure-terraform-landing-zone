

resource "azurerm_recovery_services_vault" "vault" {
  name                = "rsv-${var.client_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard" # Options: "Standard", "RS0"

  # 1. Redundancy & Recovery Features
  storage_mode_type            = "GeoRedundant" # Options: "GeoRedundant", "LocallyRedundant", "ZoneRedundant"

  cross_region_restore_enabled = false           # True enables restores in paired regions (Requires GeoRedundant)

  # 2. Security, Erasure Prevention & Immutability
  #soft_delete_enabled = true       # Retains deleted backups for 14 days.Azure currently does this by default.
  immutability        = "Locked" # Options: "Locked", "Unlocked", "Disabled"

  # 3. Network Isolation
  public_network_access_enabled = true # Blocks public internet access; forces private endpoint usage


  # 4. Identity Management (For CMK or private link access)
  identity {
    type = "SystemAssigned" # Options: "SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"
    # identity_ids = [var.user_assigned_identity_id] # Required if using UserAssigned
  }

  # 5. Customer-Managed Key (CMK) Encryption
  # Note: Requires configuring an "identity" block above
  encryption {
    key_id = var.key_vault_key_id# Optional: uses keyvaut encryption keys. If null, defaults to Microsoft-managed keys
    infrastructure_encryption_enabled = true # Double encryption at rest
    #use_system_assigned_identity = true  # Defaults to true if system assigned is used
  }
  # 6. Monitoring and Native Alerts
  monitoring {
    alerts_for_all_job_failures_enabled            = true # Toggles built-in Azure Monitor alerts
    alerts_for_critical_operation_failures_enabled = true # Toggles legacy/classic security alerts
  }
    tags = var.tags
}
##############
# Optional: Resource Guard for Backup (Prevents Accidental Deletion)and ransomware protection
resource "azurerm_data_protection_backup_vault" "modern_backup_vault" {# Modern Backup Vault with enhanced security features

  name                = "bv-${var.client_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  datastore_type      = "VaultStore"
  redundancy          = "GeoRedundant"
  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}

resource "azurerm_data_protection_resource_guard" "backup_guard" {# Resource Guard for Backup Vaults

  name                = "guard-${var.client_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags = var.tags
}

# Associate the Backup Vault with the Resource Guard for enhanced protection
resource "azurerm_recovery_services_vault_resource_guard_association" "backup_guard_assoc" {
  vault_id          = azurerm_recovery_services_vault.vault.id
  resource_guard_id = azurerm_data_protection_resource_guard.backup_guard.id
}



resource "azurerm_backup_policy_vm" "daily" {
  name                = "daily-vm-backup-policy"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 30
  }
}