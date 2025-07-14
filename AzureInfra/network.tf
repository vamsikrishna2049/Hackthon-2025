# Resource Group Creation
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name # Name of the Resource Group
  location = var.location            # Azure Region where the RG will be deployed
  tags     = var.tags                # Resource Tags (for cost management, environment info)
}

# Create a Virtual Network (VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_group_name}-vnet" # VNet name derived from RG name
  address_space       = [var.vnet_cidr]                   # CIDR range for the VNet
  location            = var.location                      # Same location as Resource Group
  resource_group_name = azurerm_resource_group.rg.name    # Link to the created Resource Group
  tags                = var.tags                          # Apply the same tags
}

# Create a Public Subnet
resource "azurerm_subnet" "public" {
  name                 = "${var.resource_group_name}-vnet-public-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.public_subnet_cidr]
}

# Create a Private Subnet
resource "azurerm_subnet" "private" {
  name                 = "${var.resource_group_name}-vnet-private-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_subnet_cidr]
}

#Create a Bastion Subnet
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet" #name must be same
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.bastion_subnet_cidr]
}

#Create a Public IP Address
resource "azurerm_public_ip" "nat" {
  name                = "${var.resource_group_name}-vnet-nat-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

#Create a NAT Gateway
resource "azurerm_nat_gateway" "natgw" {
  name                = "${var.resource_group_name}-vnet-nat-gateway"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "nat_assoc_ip" {
  nat_gateway_id       = azurerm_nat_gateway.natgw.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "nat_assoc" {
  subnet_id      = azurerm_subnet.private.id
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.resource_group_name}-vnet-vm-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

#Locals - 
locals {
  allowed_ports = var.allowed_ports
}

#Security Groups - Port
resource "azurerm_network_security_group" "web_nsg" {
  name                = "${var.resource_group_name}-vnet-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "inbound_rules" {
  for_each = { for idx, port in local.allowed_ports : "rule-${port}" => port }

  name                        = each.key
  priority                    = 100 + each.value # priority must be unique and < 4096
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = tostring(each.value)
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.web_nsg.name
  resource_group_name         = var.resource_group_name
}
