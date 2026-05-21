output "key_vault_id" {
  description = "The ID of the Key Vault for storing VM secrets"
  value       = azurerm_key_vault.kv.id
}

output "key_vault_uri" {
  value = azurerm_key_vault.kv.vault_uri
}

output "backup_key_id" {
  value = azurerm_key_vault_key.backup_cmk.id
}