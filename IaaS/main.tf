# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

resource "azurerm_resource_group" "rg" {
  name     = "Matthias_Ostermaier"
  location = "westeurope"
   tags     = {
    "cost center" = "TI"
    "environment" = "dev"
  }
}

resource "azurerm_virtual_network" "cs-vnet" {
  name                = "cloud-school-virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "cs-subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.cs-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "cs-pubip" {
  name                = "cloud-school-public-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "cs-nic" {
  name                = "cloud-school-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cs-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.cs-pubip.id
  }
}

resource "azurerm_linux_virtual_machine" "cs-vm" {
  name                = "cloud-school-machine"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_A1_v2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.cs-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    #TODO: Add your public ssh key
    public_key = file("/mnt/d/Entwicklung/mw-cloud-school/IaaS/keys/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "cs-vm-schedule" {
  virtual_machine_id = azurerm_linux_virtual_machine.cs-vm.id
  location           = azurerm_resource_group.rg.location
  enabled            = true

  daily_recurrence_time = "2300"
  timezone              = "W. Europe Standard Time"

  notification_settings {
    enabled         = false   
  }
}
