

variable "linuxvm_count" {
  type = number
}

variable "vm_name" {
  type = string
}

variable "sku" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "log_analytics_id" {
  type        = string
  description = "The ID of the Log Analytics Workspace for VM diagnostics"
}

variable "tags" {
  type = map(string)
}

