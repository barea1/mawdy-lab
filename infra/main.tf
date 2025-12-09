resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
}

# -------------------------------------------------------------------------
# NETWORKING
# -------------------------------------------------------------------------

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_cidr
}

resource "azurerm_network_security_group" "nsg_apps" {
  name                = "nsg-apps-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-Web-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet" "snet_apps" {
  name                 = "snet-apps"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_apps_cidr

  delegation {
    name = "aca-delegation"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

  service_endpoints = ["Microsoft.Sql"]
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.snet_apps.id
  network_security_group_id = azurerm_network_security_group.nsg_apps.id
}

# -------------------------------------------------------------------------
# DATABASE
# -------------------------------------------------------------------------

resource "azurerm_mssql_server" "sqlserver" {
  name                         = "sql-${var.project_name}-${var.environment}-${random_string.suffix.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_user
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"
}

resource "azurerm_mssql_database" "db" {
  name                 = var.sql_db_name
  server_id            = azurerm_mssql_server.sqlserver.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  sku_name             = var.sql_sku
  max_size_gb          = 2
  storage_account_type = "Local"
}

resource "azurerm_mssql_virtual_network_rule" "sql_vnet_rule" {
  name      = "allow-aca-subnet"
  server_id = azurerm_mssql_server.sqlserver.id
  subnet_id = azurerm_subnet.snet_apps.id
}

# -------------------------------------------------------------------------
# CONTAINER REGISTRY
# -------------------------------------------------------------------------

resource "azurerm_container_registry" "acr" {
  name                = "acr${replace(var.project_name, "-", "")}${var.environment}${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.acr_sku
  admin_enabled       = true
}

# -------------------------------------------------------------------------
# CONTAINER APPS ENVIRONMENT
# -------------------------------------------------------------------------

resource "azurerm_container_app_environment" "aca_env" {
  name                     = "aca-env-${var.project_name}-${var.environment}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  infrastructure_subnet_id = azurerm_subnet.snet_apps.id

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}
