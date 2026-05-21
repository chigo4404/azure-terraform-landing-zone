#variable "vnet_name" {}
variable "location" {}
variable "resource_group_name" {}
#variable "address_space" {}
#variable "subnet_name" {}
variable "tags" {
  type = map(string)
}
variable "route_table_name" {}
variable "environment" {
  type = string
}

variable "firewall_private_ip" {
  type        = string
  description = "The private IP address of the Azure Firewall for routing purposes"
}
# This variable is used to specify the private IP address of the Azure Firewall, which is necessary for creating routes that direct traffic to the firewall for inspection. In a typical hub-and-spoke network architecture, you would have a route in the spoke virtual network's route table that sends all outbound traffic (
variable "subnet_id" {
  type        = string
  description = "The ID of the subnet to associate with the route table"
}


variable "hub_management_subnet_id" {

  type = string
}


variable "route_table_id" {
  type = string
}
