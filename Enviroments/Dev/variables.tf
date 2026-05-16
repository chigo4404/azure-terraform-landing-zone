variable "azure_region" { type = string }
#variable "dev_vnet_address_space" { type = string }
#variable "dev_subnet_names"       { type = list(string) }
#variable "dev_subnet_prefixes"    { type = list(string) }
variable "linuxvm_count" {
  default = 1
}

variable "windowsvm_count" {
  default = 1
}

variable "vm_size" { type = string }
variable "client_name" { type = string }
variable "environment" { type = string }

variable "resource_tags" {
  type        = map(string)
  description = "Tags to be applied to all resources for governance"
}

#Automatically detect the current user's Object ID and Tenant ID now in place in the Security Module
/*
variable "admin_object_id" {
  type        = string
  description = "The Azure AD Object ID of the user who needs access to the Vault"
}
variable "tenant_id" {
  type        = string
  description = "The Azure Tenant ID"
}
*/

variable "admin_email" {
  type        = string
  description = "The email address of the administrator"
}

variable "budget_amount" {
  type        = number
  description = "The amount for the budget in USD"
}

############################################################################################
#for Landing Zone Modules


variable "admin_ip" { type = string }
variable "location" {

}

variable "tags" {
  type = map(string)
}


#putting a toggle for enabling/disabling bastion host deployment in the landing zone,
# default is false to avoid unnecessary costs during development and testing. Can be set to true when deploying to production or when bastion host is needed for secure access to VMs.  
variable "enable_bastion" {
  type    = bool
  default = false
}

# Toggle for enabling/disabling Azure Firewall deployment in the landing zone, default is false to avoid unnecessary costs during development and testing. Can be set to true when deploying to production or when advanced network security is required.
variable "enable_firewall" {
  type    = bool
  default = false
}


variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

/*
variable "enable_test_vm" {
  type    = bool
  default = false
}
*/