# Create the SSHkey Gen public_ip_address_id
# ssh-keygen -t rsa
# It will generate ssh key pair in the destination location

#
resource "azurerm_windows_virtual_machine" "windows_vm" {
  name                  = "${var.resource_group_name}-windows-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = "Standard_B1ms"
  admin_username        = "azureuser"
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.vm_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  tags = var.tags
}