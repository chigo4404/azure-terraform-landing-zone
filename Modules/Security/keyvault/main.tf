data "azurerm_client_config" "current" {}
resource "azurerm_key_vault" "kv" {

  name                = "kv-${var.client_name}-${var.environment}"

  location            = var.location

  resource_group_name = var.rg_name

  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name            = "standard"

  enable_rbac_authorization = true
}
resource "azurerm_role_assignment" "keyvault_admin" {

  scope = azurerm_key_vault.kv.id

  role_definition_name = "Key Vault Administrator"

  principal_id = data.azurerm_client_config.current.object_id
  #principal_id         = "55804bf6-9a09-44e4-acd0-d367e008e9b7"
}
resource "time_sleep" "wait_for_rbac" {
    depends_on = [azurerm_role_assignment.keyvault_admin]
    
    create_duration = "180s"
}
resource "azurerm_key_vault_key" "backup_cmk" {

  name = "backup-cmk"

  key_vault_id = azurerm_key_vault.kv.id

  key_type = "RSA"

  key_size = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]
  depends_on = [
    time_sleep.wait_for_rbac
  ]
}