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

#variable "vnet_name" {
#  type        = string
#  description = "Name of the Virtual Network"
#}

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

# variable "allowed_ports" {
#   type    = list(number)
#   default = [80, 443] # HTTP, HTTPS
# }

variable "admin_password" {
  type        = string
  description = "VM Machine Password"
  default     = "Test@123"
}


variable "secure_ports" {
  description = "Map of secure ports and their allowed sources"
  type = map(object({
    port   = number
    source = string
  }))
  default = {
    rdp = {
      port   = 3389
      source = "10.0.3.0/24"   # Example Bastion Subnet CIDR
    }
    http = {
      port   = 80
      source = "10.0.2.0/24"   # Example App Gateway Subnet CIDR
    }
    https = {
      port   = 443
      source = "10.0.2.0/24"
    }
    sql = {
      port   = 1433
      source = "10.0.1.0/24"   # Example App Subnet CIDR
    }
  }
}
