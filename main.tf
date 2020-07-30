provider "azurerm" {
  version = "2.20.0"
  features {}
}



module "asis" {
  source = "./azure-scale-set"
  environment = "production"
  location = "eastasia"
  time_zone = "GMT Standard Time"
  out_hour = 22
  out_minute = 30
  in_hour = 2
  in_minute = 30
}


module "uk" {
  source = "./azure-scale-set"
  environment = "development"
  location = "uksouth"
  time_zone = "GMT Standard Time"
  out_hour = 17
  out_minute = 30
  in_hour = 9
  in_minute = 0
}


module "france" {
  source = "./azure-scale-set"
  environment = "staging"
  location = "francecentral"
  time_zone = "GMT Standard Time"
  out_hour = 22
  out_minute = 30
  in_hour = 2
  in_minute = 30
}

