variable "nsg_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "admin_ip" {}

variable "enable_ssh" {
  default = false
}

variable "tags" {
  type = map(string)
}