variable "vnet_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "address_space" {}
#variable "subnet_name" {}
variable "tags" {
  type = map(string)
}

/*variable "subnet_name" {
  type = string
}

variable "subnet_prefix" {
  type = string
}
*/