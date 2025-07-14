# Resource Group Creation
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Virtual Network Creation
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_group_name}-vnet"
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

# Subnets Creation - Public
resource "azurerm_subnet" "public_subnet" {
  name                 = "${var.resource_group_name}-public-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.public_subnet_cidr]
}

# Subnets Creation - Private
resource "azurerm_subnet" "private_subnet" {
  name                 = "${var.resource_group_name}-private-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_subnet_cidr]
}

# Subnets Creation - Bastion
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet" # Must be exact for Azure Bastion
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.bastion_subnet_cidr]
}


# Public IP for NAT Gateway
resource "azurerm_public_ip" "nat_public_ip" {
  name                = "${var.resource_group_name}-nat-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}


# NAT Gateway and Associations
resource "azurerm_nat_gateway" "nat_gateway" {
  name                = "${var.resource_group_name}-nat-gateway"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "nat_ip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gateway.id
  public_ip_address_id = azurerm_public_ip.nat_public_ip.id
}

resource "azurerm_subnet_nat_gateway_association" "nat_subnet_assoc" {
  subnet_id      = azurerm_subnet.private_subnet.id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id
}

# Network Interface for VM (Private Subnet)
resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.resource_group_name}-vm-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# Network Security Group (NSG) and Dynamic Inbound Rules
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.resource_group_name}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

# Associate NSG to Private Subnet (for VM)
resource "azurerm_subnet_network_security_group_association" "private_subnet_assoc" {
  subnet_id                 = azurerm_subnet.private_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Allow particular Port Traffic
# resource "azurerm_network_security_rule" "inbound_rules" {
#   for_each = { for port in var.allowed_ports : "allow-port-${port}" => port }
# 
#   name                        = each.key
#   priority                    = 100 + each.value
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = tostring(each.value)
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   network_security_group_name = azurerm_network_security_group.nsg.name
#   resource_group_name         = azurerm_resource_group.rg.name
# }
# 
# 
# # Locals for Allowed Ports (Optional)
# locals {
#   allowed_ports = var.allowed_ports
# }

resource "azurerm_network_security_rule" "secure_inbound_rules" {
  for_each = var.secure_ports

  name                        = "allow-${each.key}"
  priority                    = 100 + index(keys(var.secure_ports), each.key) * 10
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = tostring(each.value.port)
  source_address_prefix       = each.value.source
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = azurerm_resource_group.rg.name
}
