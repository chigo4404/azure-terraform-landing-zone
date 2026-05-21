variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "hub_vnet_name" {
  type = string
}

variable "tags" {
  type = map(string)
}
variable "environment" {

  type = string

}