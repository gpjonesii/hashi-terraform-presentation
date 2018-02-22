resource "azurerm_resource_group" "dsvmresourcegroup" {
    name     = "dsvmResourceGroup"
    location = "East US"

    tags {
        environment = "${var.environment}"
    }
}

resource "azurerm_virtual_network" "dsvmnetwork" {
    name                = "dsvmVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.dsvmresourcegroup.name}"

    tags {
        environment = "${var.environment}"
    }
}

resource "azurerm_subnet" "dsvmsubnet" {
    name                 = "dsvmSubnet"
    resource_group_name  = "${azurerm_resource_group.dsvmresourcegroup.name}"
    virtual_network_name = "${azurerm_virtual_network.dsvmnetwork.name}"
    address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "dsvmpublicip" {
    name                         = "dsvmPublicIP"
    location                     = "${var.location}"
    resource_group_name          = "${azurerm_resource_group.dsvmresourcegroup.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "${var.environment}"
    }
}

resource "azurerm_network_security_group" "dsvmpublicipnsg" {
    name                = "dsvmNetworkSecurityGroup"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.dsvmresourcegroup.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "JUPYTER"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8081"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "TENSORBOARD"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "6006"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "RSTUDIOSERVER"
        priority                   = 1004
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8787"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "JUPYTERLAB"
        priority                   = 1005
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8888"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "JUPYTERHUB"
        priority                   = 1006
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8000"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
   
    tags {
        environment = "${var.environment}"
    }
}

resource "azurerm_network_interface" "dsvmnic" {
    name                = "dsvmNIC"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.dsvmresourcegroup.name}"
    network_security_group_id = "${azurerm_network_security_group.dsvmpublicipnsg.id}"
    ip_configuration {
        name                          = "dsvmNicConfiguration"
        subnet_id                     = "${azurerm_subnet.dsvmsubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.dsvmpublicip.id}"
    }

    tags {
        environment = "${var.environment}"
    }
}

resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.dsvmresourcegroup.name}"
    }

    byte_length = 8
}

resource "azurerm_storage_account" "dsvmstorageaccount" {
    name                = "diag${random_id.randomId.hex}"
    resource_group_name = "${azurerm_resource_group.dsvmresourcegroup.name}"
    location            = "${var.location}"
    account_tier        = "Standard"
    account_replication_type = "LRS"

    tags {
        environment = "${var.environment}"
    }
}

resource "azurerm_virtual_machine" "dsvmvm" {
    name                  = "dsvmVM"
    location              = "${var.location}"
    resource_group_name   = "${azurerm_resource_group.dsvmresourcegroup.name}"
    network_interface_ids = ["${azurerm_network_interface.dsvmnic.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "dsvmOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "microsoft-ads"
        offer     = "linux-data-science-vm-ubuntu"
        sku       = "linuxdsvmubuntu"
        version   = "latest"
    }
    
    plan {
        name = "linuxdsvmubuntu"
        publisher = "microsoft-ads"
        product = "linux-data-science-vm-ubuntu"
    }

    os_profile {
        computer_name  = "dsvm"
        admin_username = "azureuser"
        admin_password = "MScntk2017!"
    }

    os_profile_linux_config {
        disable_password_authentication = false
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "${var.key_data}"
        }
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = "${azurerm_storage_account.dsvmstorageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "${var.environment}"
    }
}
