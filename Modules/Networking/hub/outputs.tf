output "vnet_id" {
  value = azurerm_virtual_network.hub_vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.hub_vnet.name
}





output "hub_vnet_id" {
  value = azurerm_virtual_network.hub_vnet.id
}



output "shared_subnet_id" {
  value = azurerm_subnet.shared.id
}
output "bastion_subnet_id" {
  value = azurerm_subnet.bastion.id
}


output "management_subnet_id" {
  value = azurerm_subnet.management.id
}

output "firewall_subnet_id" {
  value = azurerm_subnet.firewall.id
}



