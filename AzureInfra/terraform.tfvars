# ----------------------
# terraform.tfvars
# ----------------------
resource_group_name = "azure-secure-rg"
location            = "centralus"
vnet_name           = "Sentinel-Pro"
vnet_cidr           = "10.0.0.0/16"
public_subnet_cidr  = "10.0.10.0/24"
private_subnet_cidr = "10.0.20.0/24"
bastion_subnet_cidr = "10.0.3.0/27"
sql_admin_username  = "sqladminuser"
sql_admin_password  = "<REPLACE_WITH_STRONG_PASSWORD>"
tags = {
  environment = "Dev"
  owner       = "vamsi"
  project     = "ATM-Sentinel"
}
