terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "dev" {
  name = "rg-${var.client_name}-${var.environment}"
  # CHANGE THIS: Use the variable from your .tfvars
  location = var.azure_region
}

module "linux_vm" {
  #source    = "../../Modules/Compute"
  source = "../../Modules/Compute/linux-vm"


  # CHANGE THESE: Match the names in your .tfvars
  linuxvm_count = var.linuxvm_count
  sku           = var.vm_size
  #vm_name   = "web-server-dev" # not standard naming. change to use variables for consistency
  vm_name = "vm-${var.client_name}-${var.environment}" # Using variables for naming consistency. change 'vm' to "web-server" 
  #if you want web servers as vm names instead of generic vm names. also change the output variable name in outputs.tf to match the new naming convention 
  # ... rest of your code

  #subnet_id = module.networking.subnet_ids[0] # The 'web' subnet
  subnet_id = module.spoke.app_subnet_id # Updated to use Spoke module output

  rg_name        = azurerm_resource_group.dev.name
  location       = azurerm_resource_group.dev.location
  ssh_public_key = file("./id_rsa.pub")

  # i hardcoded the tags for the servers. so this variable isnt needed. ucomment the below if you want to use variables for tags instead of hardcoding
  tags = var.resource_tags

  #log_analytics_id = module.monitoring.log_analytics_id # Linking Compute to Monitoring for enhanced insights
  log_analytics_id = azurerm_log_analytics_workspace.law.id # Linking Compute to Monitoring for enhanced insights
}


module "windows_vm" {

  source = "../../Modules/Compute/windows-vm"

  windowsvm_count = var.windowsvm_count

  vm_name = "win-${var.client_name}-${var.environment}"

  vm_size = var.vm_size

  subnet_id = module.spoke.app_subnet_id

  resource_group_name = azurerm_resource_group.dev.name

  location = azurerm_resource_group.dev.location

  admin_username = var.admin_username

  admin_password = var.admin_password

  tags = var.resource_tags

  #log_analytics_id = azurerm_log_analytics_workspace.law.id
}

module "management_windows_vm" {

  source = "../../Modules/Compute/windows-vm"

  windowsvm_count = 1

  vm_name = "mgmt-${var.client_name}-${var.environment}"

  vm_size = var.vm_size

  subnet_id = module.hub.management_subnet_id

  resource_group_name = azurerm_resource_group.dev.name

  location = azurerm_resource_group.dev.location

  admin_username = var.admin_username

  admin_password = var.admin_password

  tags = merge(
    var.resource_tags,
    {
      role = "management"
    }
  )
}



module "sql_db" {
  source   = "../../Modules/Database"
  rg_name  = azurerm_resource_group.dev.name
  location = azurerm_resource_group.dev.location
  #db_name        = "customer-dev-db"
  db_name        = "${var.client_name}db" ## Using variables for naming
  admin_user     = "sqladmin"
  admin_password = "ComplexPassword123!" # Ideally use KeyVault
  tags           = var.resource_tags

  #log_analytics_id = module.monitoring.log_analytics_id # Linking Database to Monitoring for enhanced insights
  log_analytics_id = azurerm_log_analytics_workspace.law.id # Linking Database to Monitoring for enhanced insights
}

# Security Module (Linked to Networking)
module "keyvault" {
  source = "../../Modules/Security/keyvault"
  # AUTO-DETECT these instead of using variables:
  admin_object_id = data.azurerm_client_config.current.object_id
  tenant_id       = data.azurerm_client_config.current.tenant_id
  client_name     = "chigo-corp"
  rg_name         = azurerm_resource_group.dev.name
  location        = azurerm_resource_group.dev.location
  environment     = "dev"
  #target_subnet_id = module.networking.subnet_ids[0] # Links Security to Network
  target_subnet_id = module.spoke.app_subnet_id # Updated to use Spoke module output

  /* using variables
   location        = azurerm_resource_group.dev.location
   vnet_name       = "vnet-${var.client_name}"
  address_space   = var.dev_vnet_address_space
  subnet_names    = var.dev_subnet_names
  subnet_prefixes = var.dev_subnet_prefixes
  */
}
module "governance" {
  #source ="../../Policies"
  source   = "../../Policies/deny-public-ip"
  location = var.azure_region
}
# Data source to get current Azure AD user info for RBAC assignments
data "azurerm_client_config" "current" {}


###################################

module "monitoring" {
  source      = "../../Modules/Monitoring"
  client_name = var.client_name
  environment = var.environment
  location    = azurerm_resource_group.dev.location
  rg_name     = azurerm_resource_group.dev.name
  rg_id       = azurerm_resource_group.dev.id # New link
  #admin_email   = "your-email@domain.com"
  admin_email = var.admin_email
  #budget_amount = 50 # Set $50 budget for Dev
  budget_amount   = var.budget_amount
  tags            = var.resource_tags
  sql_database_id = module.sql_db.sql_database_id # Pass the SQL Database ID for monitoring linkage
  #vm_ids = [azurerm_linux_virtual_machine.vm.id]
  vm_ids           = module.linux_vm.vm_id
  log_analytics_id = azurerm_log_analytics_workspace.law.id
}


resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${var.client_name}-${var.environment}"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
  sku                 = "PerGB2018"

  tags = var.resource_tags
}

#################################################################################################
#New infrastructure 
# This main.tf file is the entry point for the Dev environment. It orchestrates the deployment of all modules and resources specific to the Dev environment, ensuring that they are properly linked together through variables and outputs.
# Key points: 
# 1. Resource Group: A resource group is created for the Dev environment, and its name and location are passed to all modules to ensure resources are organized correctly.
# 2. Modules: The main.tf file calls the Networking, Compute, Database, Security, and Monitoring modules, passing necessary variables to each. This modular approach promotes reusability and separation of concerns.
# 3. Variable Usage: Variables are used extensively to allow for customization and flexibility. For example, the VM names, database names, and tags are all generated using variables to maintain consistency and make it easy to manage across different environments.
# 4. Monitoring Integration: The Compute and Database modules are linked to the Monitoring module through the log analytics workspace ID, enabling enhanced monitoring and insights for the resources deployed in the Dev environment.  


#new enterprize landing zone template.module "name" {
#  source = "../../Modules/ModuleName"
#  # Pass necessary variables here

module "app_nsg" {
  source              = "../../Modules/Networking/nsg"
  nsg_name            = "nsg-app-dev"
  location            = var.location
  resource_group_name = local.resource_group_name

  enable_ssh = true
  admin_ip   = var.admin_ip

  tags = local.common_tags
}

# creating a NSG module for the Data Subnet with no SSH access
module "data_nsg" {
  source              = "../../Modules/Networking/nsg"
  nsg_name            = "nsg-data-dev"
  location            = var.location
  resource_group_name = local.resource_group_name

  enable_ssh = false
  admin_ip   = var.admin_ip

  tags = local.common_tags
}

# Route Table Module
module "route_table" {
  source              = "../../Modules/Networking/route-table"
  route_table_name    = "rt-dev"
  location            = var.location
  resource_group_name = local.resource_group_name
  #firewall_private_ip = module.azure_firewall[0].firewall_private_ip
   # Safe conditional lookup: returns null if azure_firewall is not deployed
  firewall_private_ip = length(module.azure_firewall) > 0 ? module.azure_firewall[0].firewall_private_ip : null
  environment = var.environment
  tags = local.common_tags
  subnet_id = module.spoke.app_subnet_id
  hub_management_subnet_id = module.hub.management_subnet_id
  route_table_id = module.route_table.hub_route_table_id
}


module "hub_route_table" {

  source = "../../Modules/Networking/route-table"

  route_table_name = "rt-hub-${var.environment}"

  location          = var.azure_region

  resource_group_name = local.resource_group_name

  #firewall_private_ip = module.azure_firewall[0].firewall_private_ip
  # Safe conditional lookup: returns null if azure_firewall is not deployed
  firewall_private_ip = length(module.azure_firewall) > 0 ? module.azure_firewall[0].firewall_private_ip : null

  subnet_id = module.hub.management_subnet_id
  environment = var.environment
  hub_management_subnet_id = module.hub.management_subnet_id
  route_table_id = module.route_table.hub_route_table_id

  tags = local.common_tags
}

# Spoke Network Module for Dev environment
module "spoke" {
  source              = "../../Modules/Networking/spoke"
  vnet_name           = "vnet-spoke-dev"
  location            = var.location
  resource_group_name = local.resource_group_name

  address_space = ["10.1.0.0/16"]

  app_nsg_id  = module.app_nsg.nsg_id
  data_nsg_id = module.data_nsg.nsg_id

  route_table_id = module.route_table.spoke_route_table_id #uncomment also in spoke main and variables.tf to use route tables in the spoke. currently commented out as firewall is not yet deployed and route table is dependent on firewall private IP for routing rules. once firewall is deployed and we have the private IP, we can uncomment the route table module and related variables to enable routing through the firewall.

  tags = local.common_tags
}

module "hub" {
  source = "../../Modules/Networking/hub"

  vnet_name           = "vnet-hub-dev"
  location            = var.location
  resource_group_name = local.resource_group_name

  address_space = ["10.0.0.0/16"]
  management_nsg_id = module.app_nsg.nsg_id

  tags = local.common_tags

}


#
module "peering" {
  source              = "../../Modules/Networking/peering"
  location            = var.location
  resource_group_name = local.resource_group_name

  hub_vnet_name = module.hub.vnet_name
  hub_vnet_id   = module.hub.vnet_id

  spoke_vnet_name = module.spoke.vnet_name
  spoke_vnet_id   = module.spoke.vnet_id

  tags = local.common_tags
}




# Module for Private DNS Zone
module "private_dns" {
  source = "../../Modules/Networking/private-dns"

  resource_group_name = local.resource_group_name

  vnet_id = module.spoke.vnet_id

  tags = local.common_tags
}


module "private_endpoint" {
  source = "../../Modules/Networking/private-endpoint"

  private_endpoint_name = local.private_endpoint_name

  location            = var.location
  resource_group_name = local.resource_group_name

  subnet_id = module.spoke.private_endpoint_subnet_id

  storage_account_id = module.storage.storage_account_id

  private_dns_zone_id = module.private_dns.private_dns_zone_id

  tags = local.common_tags
}

#storage module
module "storage" {
  source = "../../Modules/Storage"

  storage_account_name = "stdevlandingzone01"

  resource_group_name = local.resource_group_name
  location            = var.location

  tags = local.common_tags
}




module "bastion" {
  count  = var.enable_bastion ? 1 : 0
  source = "../../Modules/Networking/bastion"

  resource_group_name = local.resource_group_name
  location            = var.azure_region

  hub_vnet_name = module.hub.vnet_name
  hub_vnet_id   = module.hub.vnet_id

  tags = local.common_tags
}

# Firewall Module - Deployed in Hub for centralized security  
module "azure_firewall" {
  count = var.enable_firewall ? 1 : 0

  source = "../../Modules/Networking/azure-firewall"

  resource_group_name = local.resource_group_name
  environment = var.environment
  location            = var.azure_region
  hub_vnet_name       = module.hub.vnet_name

  tags = local.common_tags
}


# Backup Module - Linked to Compute and Database for data protection and recovery
module "backup" {
  source = "../../Modules/Backup"
key_vault_key_id = module.keyvault.backup_key_id
  client_name = var.client_name
  environment = var.environment
  location            = var.azure_region
  resource_group_name = local.resource_group_name

  tags = local.common_tags
}



module "backup_governance" {

  source = "../../Policies/enforce-backup"

  location = var.azure_region

  recovery_vault_name = module.backup.vault_name

  backup_policy_id           = module.backup.backup_policy_id
  backup_resource_group_name = local.resource_group_name
}

##########################################################################
# Below are the RBAC Role Assignments for Backup Governance - Granting necessary permissions to the policy's managed identity to enforce backup compliance on VMs and databases across the subscription. This ensures that the policy can effectively audit and enforce backup requirements on all relevant resources, providing a critical layer of governance and security for the landing zone.
data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "policy_backup_contributor" {

  scope = data.azurerm_subscription.current.id

  role_definition_name = "Backup Contributor"

  principal_id = module.backup_governance.policy_principal_id
}

resource "azurerm_role_assignment" "policy_vm_contributor" {

  scope = data.azurerm_subscription.current.id

  role_definition_name = "Virtual Machine Contributor"

  principal_id = module.backup_governance.policy_principal_id
}

########################################################################################## END of assignments for backup governance
# Below is a null_resource that triggers the remediation of existing non-compliant resources after the policy assignment is created. This ensures that any VMs or databases that do not meet the backup requirements are automatically remediated to comply with the policy, providing immediate enforcement of backup governance across the subscription.
resource "null_resource" "trigger_backup_remediation" {

  provisioner "local-exec" {

    command = <<EOT
az policy remediation create --name backup-remediation --policy-assignment auto-enable-prod-vm-backup
EOT

  }

  depends_on = [
    module.backup_governance,
    azurerm_role_assignment.policy_backup_contributor,
    azurerm_role_assignment.policy_vm_contributor,
  ]
}