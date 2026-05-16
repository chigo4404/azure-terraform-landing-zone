output "resource_group_name" {
  value = azurerm_resource_group.dev.name
}
/*
output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = module.networking.vnet_id 
}
*/
output "vm_private_ips" {
  description = "The private IP addresses of the virtual machines"
  value       = module.linux_vm.private_ip_addresses
}

output "sql_server_fqdn" {
  description = "The fully qualified domain name of the SQL Server"
  value       = module.sql_db.sql_server_fqdn
}




################################################################################
# Outputs for Networking Modules
output "spoke_vnet_id" {
  value = module.spoke.vnet_id
}

output "spoke_vnet_name" {
  value = module.spoke.vnet_name
}


output "storage_account_id" {
  value = module.storage.storage_account_id
}
output "private_dns_zone_id" {
  value = module.private_dns.private_dns_zone_id
}


output "private_endpoint_subnet_id" {
  value = module.spoke.private_endpoint_subnet_id
}


output "policy_assignment_ids" {
  value = module.governance.policy_assignment_ids
}