
##############

output "vnet_id" {
  description = "Spoke VNet ID"
  value       = azurerm_virtual_network.spoke_vnet.id
}

output "vnet_name" {
  description = "Spoke VNet Name"
  value       = azurerm_virtual_network.spoke_vnet.name
}

output "app_subnet_id" {
  description = "Application subnet ID"
  value       = azurerm_subnet.app.id
}

output "data_subnet_id" {
  description = "Data subnet ID"
  value       = azurerm_subnet.data.id
}

output "private_endpoint_subnet_id" {
  description = "Private Endpoint subnet ID"
  value       = azurerm_subnet.private_endpoints.id
}