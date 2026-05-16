
variable "private_endpoint_name" {}

variable "location" {}

variable "resource_group_name" {}

variable "subnet_id" {}

variable "storage_account_id" {}

variable "private_dns_zone_id" {}

variable "tags" {
  type = map(string)
}