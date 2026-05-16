#variable "vnet_name" {}
variable "location" {}
variable "resource_group_name" {}
#variable "address_space" {}
#variable "subnet_name" {}
variable "tags" {
  type = map(string)
}
variable "route_table_name" {}
