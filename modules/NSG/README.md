module "nsg_management" {
  source              = "./modules/NSG"
  name                = "nsg-mgmt-hub-weu-01"
  location            = "westeurope"
  resource_group_name = module.rg.name

  security_rules = [
    {
      name                       = "Allow-SSH-Inbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "10.0.0.0/8"
      destination_address_prefix = "*"
    }
  ]

  tags = {
    environment = "lab"
    project     = "neko"
  }
}