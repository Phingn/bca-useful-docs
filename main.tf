provider "azurerm" {
    version = "2.0.0"
    subscription_id = var.subscriptionID

    features {}
}

resource "azurerm_network_security_group" "matrixSecurityGroup" {
    name                        = "matrixSecurityGroup"
    location                    = "West Europe"
    resource_group_name         = var.resourceGroupName
}

resource "azurerm_network_security_rule" "Port80" {
    name                        = "Allow80"
    priority                    = "102"
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "80"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name           = azurerm_network_security_group.matrixSecurityGroup.resource_group_name
    network_security_group_name = azurerm_network_security_group.matrixSecurityGroup.name
}

resource "azurerm_network_security_rule" "Port443" {
    name                        = "Allow443"
    priority                    = "102"
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "443"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name           = azurerm_network_security_group.matrixSecurityGroup.resource_group_name
    network_security_group_name = azurerm_network_security_group.matrixSecurityGroup.name
}

resource "azurerm_virtual_network" "matrix-vnet" {
    name                        = "matrix-vnet"
    location                    = var.location
    resource_group_name         = var.resourceGroupName
    address_space               = ["10.0.0.0/16"]
    dns_servers                 = ["8.8.8.8", "8.8.4.4"]

    tags = {
        environment = "Dev"
    }
}

resource "azurerm_subnet" "matrix-sub" {
    name                        = "testsubnet"
    resource_group_name         = azurerm_network_security_group.matrixSecurityGroup.resource_group_name
    virtual_network_name        = azurerm_virtual_network.matrix-vnet.name
    address_prefix              = "10.0.1.0/24"
}

resource "azurerm_public_ip" "matrix-publicIP" {
    name                        = "matrix-publicIP"
    location                    = var.location
    resource_group_name         = azurerm_network_security_group.matrixSecurityGroup.resource_group_name
    allocation_method           = "Static"
    ip_version                  = "IPv4"

    tags = {
        environment = "Dev"
    }

}

