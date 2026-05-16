resource "azurerm_network_interface" "nic" {
  count               = var.linuxvm_count
  name                = "nic-${var.vm_name}-${count.index}"
  location            = var.location
  resource_group_name = var.rg_name

   lifecycle {
    create_before_destroy = true
    #In production, consider adding prevent_destroy to avoid accidental deletions
    #prevent_destroy = true
  }


  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}


  # hardcoding example
  /*
   tags = {
  environment = "lab"
  owner       = "chigo"
  project     = "landing-page"
}
  */

resource "azurerm_linux_virtual_machine" "vm" {

  count = var.linuxvm_count

  name                = "${var.vm_name}-${count.index}"
  resource_group_name = var.rg_name
  location            = var.location

  size = var.sku

  admin_username = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = var.tags
 
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.ssh_public_key
  }

  identity {
    type = "SystemAssigned"
  }
}

# This resource links each VM to the Log Analytics Workspace for enhanced monitoring and diagnostics.
resource "azurerm_monitor_diagnostic_setting" "vm_diag" {
  count                      = var.linuxvm_count
  name                       = "diag-${var.vm_name}-${count.index}"
  # Points to each specific VM in the count
  target_resource_id         = azurerm_linux_virtual_machine.vm[count.index].id
  log_analytics_workspace_id = var.log_analytics_id

  # Monitoring VM Health
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
