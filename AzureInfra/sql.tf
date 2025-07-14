# Azure SQL Server
resource "azurerm_mssql_server" "sql_server" {
  name                         = "atm-sql-server-${random_integer.rand.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  tags                         = var.tags
}

# Azure SQL Database
resource "azurerm_mssql_database" "sql_db" {
  name      = "atm-sqldb"
  server_id = azurerm_mssql_server.sql_server.id
  sku_name  = "S0" # Use Basic, S0, P1, etc. based on requirement
  tags      = var.tags
}

# Random suffix (for unique SQL server names)
resource "random_integer" "rand" {
  min = 10000
  max = 99999
}

# Private Endpoint to access SQL securely within VNet
resource "azurerm_private_endpoint" "sql_pe" {
  name                = "pe-atm-sql"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.private_subnet.id

  private_service_connection {
    name                           = "psc-atm-sql"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  tags = var.tags
}

# Private DNS Zone for SQL
resource "azurerm_private_dns_zone" "sql_dns" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_link" {
  name                  = "sql-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_a_record" "sql_dns_a" {
  name                = azurerm_mssql_server.sql_server.name
  zone_name           = azurerm_private_dns_zone.sql_dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql_pe.private_service_connection[0].private_ip_address]
}