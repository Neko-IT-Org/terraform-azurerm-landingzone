###############################################################
# PALO ALTO VM-SERIES MODULE
# Description: Deploys Palo Alto Networks VM-Series firewall
# Features:
#   - 3 NICs (Management, Untrust, Trust)
#   - Bootstrap support via Azure Storage Account
#   - SSH key authentication
#   - Availability Zones support
###############################################################

###############################################################
# RESOURCE: Public IP for Management Interface
###############################################################
resource "azurerm_public_ip" "mgmt" {
  name                = "${var.firewall_name}-pip-mgmt"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.availability_zones

  tags = merge(
    var.tags,
    {
      Interface = "Management"
    }
  )
}

###############################################################
# RESOURCE: Public IP for Untrust Interface
###############################################################
resource "azurerm_public_ip" "untrust" {
  name                = "${var.firewall_name}-pip-untrust"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.availability_zones

  tags = merge(
    var.tags,
    {
      Interface = "Untrust"
    }
  )
}

###############################################################
# RESOURCE: Network Interfaces
###############################################################
resource "azurerm_network_interface" "mgmt" {
  name                = "${var.firewall_name}-nic-mgmt"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig-mgmt"
    subnet_id                     = var.mgmt_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.mgmt_private_ip
    public_ip_address_id          = azurerm_public_ip.mgmt.id
  }

  tags = merge(
    var.tags,
    {
      Interface = "Management"
    }
  )
}

resource "azurerm_network_interface" "untrust" {
  name                          = "${var.firewall_name}-nic-untrust"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "ipconfig-untrust"
    subnet_id                     = var.untrust_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.untrust_private_ip
    public_ip_address_id          = azurerm_public_ip.untrust.id
  }

  tags = merge(
    var.tags,
    {
      Interface = "Untrust"
    }
  )
}

resource "azurerm_network_interface" "trust" {
  name                          = "${var.firewall_name}-nic-trust"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "ipconfig-trust"
    subnet_id                     = var.trust_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.trust_private_ip
  }

  tags = merge(
    var.tags,
    {
      Interface = "Trust"
    }
  )
}

###############################################################
# RESOURCE: Virtual Machine (Palo Alto VM-Series)
###############################################################
resource "azurerm_linux_virtual_machine" "firewall" {
  name                = var.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username

  # Availability Zone
  zone = var.availability_zones != null ? var.availability_zones[0] : null

  # Network interfaces (order matters!)
  network_interface_ids = [
    azurerm_network_interface.mgmt.id,
    azurerm_network_interface.untrust.id,
    azurerm_network_interface.trust.id,
  ]

  # SSH authentication
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  # Disable password authentication
  disable_password_authentication = true

  # OS disk
  os_disk {
    name                 = "${var.firewall_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
  }

  # Source image (Palo Alto Marketplace)
  plan {
    name      = var.palo_sku
    publisher = "paloaltonetworks"
    product   = "vmseries-flex"
  }

  source_image_reference {
    publisher = "paloaltonetworks"
    offer     = "vmseries-flex"
    sku       = var.palo_sku
    version   = var.palo_version
  }

  # Bootstrap configuration (optional)
  custom_data = var.bootstrap_storage_account != null ? base64encode(
    templatefile("${path.module}/bootstrap-init.tpl", {
      storage_account = var.bootstrap_storage_account
      access_key      = var.bootstrap_storage_access_key
      file_share      = var.bootstrap_file_share
      share_directory = ""
    })
  ) : null

  # Boot diagnostics
  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_uri
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      custom_data,
      admin_ssh_key
    ]
  }
}

###############################################################
# TEMPLATE: Bootstrap init-cfg.txt
###############################################################
# File: bootstrap-init.tpl
# Content:
# type=dhcp-client
# ip-address=
# default-gateway=
# netmask=
# ipv6-address=
# ipv6-default-gateway=
# hostname=${var.firewall_name}
# vm-auth-key=
# panorama-server=
# panorama-server-2=
# tplname=
# dgname=
# dns-primary=168.63.129.16
# dns-secondary=
# op-command-modes=mgmt-interface-swap
# plugin-op-commands=azure-op-commands:1.0.5
# storage-account=${storage_account}
# access-key=${access_key}
# file-share=${file_share}
# share-directory=${share_directory}
###############################################################
