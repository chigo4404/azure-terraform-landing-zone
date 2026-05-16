
/*
output "policy_principal_id" {
  value = azurerm_subscription_policy_assignment.backup_assignment.identity[0].principal_id
}
*/

output "policy_principal_id" {
  value = azurerm_subscription_policy_assignment.backup_assignment.identity[0].principal_id
}