resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  public_network_access_enabled = false

  min_tls_version = "TLS1_2"

  allow_nested_items_to_be_public = false

  tags = var.tags
}


resource "azurerm_storage_container" "container" {
  name                  = "appdata"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}