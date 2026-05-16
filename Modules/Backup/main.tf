
resource "azurerm_recovery_services_vault" "vault" {
 name                = "rsv-${var.client_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku = "Standard"

  soft_delete_enabled = true

  
  tags = var.tags
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


##############
