# ----------------------
# variables.tf
# ----------------------
variable "resource_group_name" {
  type        = string
  description = "Name of the Azure resource group"
}

variable "location" {
  type        = string
  description = "Azure region to deploy resources"
}

variable "tags" {
  type        = map(string)
  description = "Common resource tags"
}

variable "vnet_name" {
  type        = string
  description = "Name of the Virtual Network"
}

variable "vnet_cidr" {
  type        = string
  description = "CIDR block for the Virtual Network"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for the public subnet"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR block for the private subnet"
}

variable "bastion_subnet_cidr" {
  type        = string
  description = "CIDR block for the Bastion subnet"
}

variable "sql_admin_username" {
  type        = string
  description = "SQL Admin username"
}

variable "sql_admin_password" {
  type        = string
  description = "SQL Admin password"
  sensitive   = true
}
