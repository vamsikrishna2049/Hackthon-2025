output "vnet_id" {
  value = azurerm_virtual_network.vnet.name
}

output "Public_SubnetID" {
  value = azurerm_subnet.public.name
}

output "Private_SubnetID" {
  value = azurerm_subnet.private.name
}

output "Bastion_SubnetID" {
  value = azurerm_subnet.bastion.name
}

output "Public_IP" {
  value = azurerm_public_ip.nat.name
}

output "natGateway_ID" {
  value = azurerm_nat_gateway.natgw.name
}

output "SecurityGroup_ID" {
  value = azurerm_network_security_group.web_nsg.name
}

output "nsg_allowed_ports" {
  value       = [for rule in azurerm_network_security_rule.inbound_rules : rule.destination_port_range]
  description = "List of allowed inbound ports from the NSG rules"
}


# Compute

# SQL
#output "sql_server_fqdn" {
#  value = azurerm_mssql_server.sql_server.fully_qualified_domain_name
#}