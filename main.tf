provider "azurerm" {
  version = "2.20.0"
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "scalesetVM"
  location = "UK South"
}

module "load-balancer" {
  source              = "./load-balancer"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  prefix              = "terraform-test"

module "azure-virtual-machine" {
  source = "./virtual-machine"
  resource_group = azurerm_resource_group.example.name
  location = azurerm_resource_group.example.location 
  user = "gumic"
  size = "Standard_B1s"
}

