provider "azurerm" {
  features {}
}

module "resource_group" {
  source      = "git::https://github.com/opsstation/terraform-azure-resource-group.git?ref=v1.0.0"
  name        = "opsstation"
  environment = "test"
  location    = "North Europe"
}

module "vnet" {
  source              = "git::https://github.com/opsstation/terraform-azure-vnet.git?ref=v1.0.0"
  name                = "app"
  environment         = "vnet"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}

module "subnet" {
  source               = "git::https://github.com/opsstation/terraform-azure-subnet.git?ref=v1.0.1"
  name                 = "app"
  environment          = "subnet"
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = join("", module.vnet[*].vnet_name)

  #subnet
  subnet_names    = ["subnet1"]
  subnet_prefixes = ["10.0.1.0/24"]

  # route_table
  enable_route_table = true
  route_table_name   = "default_subnet"
  routes = [
    {
      name           = "rt-test"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]
}
module "nat_gateway" {
  depends_on          = [module.resource_group, module.vnet]
  source              = "./../."
  name                = "app"
  environment         = "NAT"
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  subnet_ids          = module.subnet.subnet_id[0]
}
