output "vnet_name" {
  value       = azurerm_virtual_network.vnet.name
  description = "Virtual Network name"

}

output "Public_Subnet" {
  value = azurerm_subnet.public_subnet.name
}

output "Private_Subnet" {
  value = azurerm_subnet.private_subnet.name
}

output "Public_IP" {
  value       = azurerm_public_ip.nat_public_ip.ip_address
  description = "The public IP address allocated to the NAT Gateway"
}

output "natGateway" {
  value = azurerm_nat_gateway.nat_gateway.name
}

output "SecurityGroup" {
  value = azurerm_network_security_group.nsg.name
}

#output "nsg_allowed_ports" {
#  value       = [for rule in azurerm_network_security_rule.inbound_rules : rule.destination_port_range]
#  description = "List of allowed inbound ports from the NSG rules"
#}


# Compute

# SQL
#output "sql_server_fqdn" {
#  value = azurerm_mssql_server.sql_server.fully_qualified_domain_name
#}