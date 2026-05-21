output "spoke_route_table_id" {

  value = azurerm_route_table.spoke_rt.id
}

output "hub_route_table_id" {

  value = azurerm_route_table.hub_rt.id
}