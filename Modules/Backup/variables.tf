variable "client_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  type = map(string)
}
variable "key_vault_key_id" {
  type        = string
  description = "Customer Managed Key ID for Recovery Services Vault encryption"
  default     = null
}