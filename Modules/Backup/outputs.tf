output "vault_id" {
  value = azurerm_recovery_services_vault.vault.id
}

output "backup_policy_id" {
  value = azurerm_backup_policy_vm.daily.id
}

output "vault_name" {
  value = azurerm_recovery_services_vault.vault.name
}

output "backup_policy_name" {
  value = azurerm_backup_policy_vm.daily.name
}

/*
output "key_vault_key_id" {
  value = var.key_vault_key_id
}
*/
