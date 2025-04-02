terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {

  features {}
}

#data "azurerm_image" "ubuntu" {
#  name                = "UbuntuLTS"
#  resource_group_name = "platform-images"  # Azure marketplace resource group
#}

resource "azurerm_virtual_network" "VNET1" {
    name = "VNET1"
    address_space = [ "10.0.0.0/16" ]
    location = azurerm_resource_group.mainRG.location
    resource_group_name = azurerm_resource_group.mainRG.name
  
}

resource "azurerm_subnet" "PublicSubnet" {
    name = "PublicSubnet"
    resource_group_name = azurerm_resource_group.mainRG.name
    virtual_network_name = azurerm_virtual_network.VNET1.name
    address_prefixes = [ "10.0.1.0/24" 
    ]
}

resource "azurerm_network_interface" "NIC1" {
    name = "NIC1"
    location = azurerm_resource_group.mainRG.location
    resource_group_name = azurerm_resource_group.mainRG.name

    ip_configuration {
      name = "internal"
      subnet_id = azurerm_subnet.PublicSubnet.id
      private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_resource_group" "mainRG" {
  name     = "RG1"
  location = "Southeast Asia"
}



resource "azurerm_virtual_machine" "VM1" {
  name                  = "VM1"
  resource_group_name    = azurerm_resource_group.mainRG.name
  location              = azurerm_resource_group.mainRG.location
  vm_size               = "Standard_F2"
  network_interface_ids = [azurerm_network_interface.NIC1.id]

   storage_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # Define the OS disk
  storage_os_disk {
    name = "example-os-disk"
    create_option = "FromImage"
    caching       = "ReadWrite"
    os_type       = "Linux"
    disk_size_gb = 30
    
    
  }

  os_profile {
    computer_name  = "VM1"
    admin_username = "adminuser"  # Replace with your desired admin username
    admin_password = "P@ssw0rd123!"  # Replace with a secure password, or use ssh_keys instead
  }

  os_profile_linux_config {
    disable_password_authentication = false  # Set to true to disable password login, or use SSH keys instead
    # Optional: Configure SSH keys if desired (recommended for better security)
    # ssh_keys {
    #   path     = "/home/adminuser/.ssh/authorized_keys"
    #   key_data = "<YOUR_PUBLIC_SSH_KEY>"
    # }
  }


 
}
