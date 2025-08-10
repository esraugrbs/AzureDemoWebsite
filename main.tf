terraform {
  required_version = ">= 1.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.104"
    }
  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "sdx-vnet"
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}


resource "azurerm_subnet" "subnet" {
  name                 = "sdx-subnet"
  address_prefixes     = [var.subnet_cidr]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}


resource "azurerm_network_security_group" "nsg" {
  name                = "sdx-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "22"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "80"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_public_ip" "pip" {
  name                = "sdx-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}


resource "azurerm_network_interface" "nic" {
  name                = "sdx-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}


resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "sdx-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location
  size                  = "Standard_B1s"
  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_username = var.admin_username
  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  #custom_data = filebase64("${path.module}/apache.sh")

  os_disk {
    name                 = "sdx-osdisk"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}


locals {
  
  website_local_dir_abs = "${path.module}/${var.website_local_dir}"

  
  website_files = fileset(local.website_local_dir_abs, "**")
  website_hash = join(
    "",
    [for f in local.website_files : filesha1("${local.website_local_dir_abs}/${f}")]
  )
}

resource "null_resource" "deploy_static_site" {
  triggers = {
    content_hash = local.website_hash
  }

 
  provisioner "file" {
    source      = local.website_local_dir_abs
    destination = "/tmp/site"
  }

  
  provisioner "file" {
    source      = "${path.module}/apache.sh"
    destination = "/tmp/apache.sh"
  }


  provisioner "remote-exec" {
    

    inline = [
      "chmod +x /tmp/apache.sh",
      "sudo /tmp/apache.sh"
    ]
  }

  connection {
    type        = "ssh"
    host        = azurerm_public_ip.pip.ip_address 
    user        = var.admin_username
    private_key = file(var.private_key_path)
  }

  depends_on = [azurerm_linux_virtual_machine.vm]
}