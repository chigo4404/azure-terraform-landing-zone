variable "hub_vnet_name" {}
variable "location" {}
variable "resource_group_name" {}
#variable "address_space" {}
#variable "subnet_name" {}
variable "spoke_vnet_id" {}
variable "hub_vnet_id" {}
variable "spoke_vnet_name" {}
variable "tags" {
  type = map(string)
}

