#The VMs will be deployed in the hub virtual network and can be accessed securely through the bastion host if enabled. 
#########################################################################################################
# for deploying multiple VMs, we can use the count parameter to create multiple instances of the VM resource. 
#This allows us to easily scale the number of VMs up or down by simply changing the count value. 
#Each VM will be created with a unique name based on the base name and the index of the count. 
#This approach is efficient for managing multiple similar resources without having to duplicate code for each instance.

resource "azurerm_network_interface" "vm_nic" {
    count = var.windowsvm_count
    name = "${var.vm_name}-nic-${count.index}"
     location   = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

#Commenting out tags for testing. In production, use variables for tags to ensure consistency and ease of management across resources.    
   #tags = var.tags

  # hardcoding example # FOR TESTING ONLY. In production, use variables for tags to ensure consistency and ease of management across resources.    
     tags = {
  environment = "production"
  owner       = "chigo"
  project     = "landing-page"
}
  

lifecycle {
    create_before_destroy = true
    #In production, consider adding prevent_destroy to avoid accidental deletions
    #prevent_destroy = true
  }

}

resource "azurerm_windows_virtual_machine" "vm" {
   count = var.windowsvm_count
 
   #name  = "${var.vm_name}-${count.index}"  

   name          = "${var.vm_name}-${count.index}"
   computer_name = "win${count.index}"

  location            = var.location
  resource_group_name = var.resource_group_name

  size           = var.vm_size
  admin_username = var.admin_username
  admin_password = var.admin_password

  network_interface_ids = [
  azurerm_network_interface.vm_nic[count.index].id
]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  provision_vm_agent = true

  #tags = var.tags
      tags = {
  environment = "production"
  owner       = "chigo"
  project     = "landing-page"
}
  
}

# This resource links each VM to the Log Analytics Workspace for enhanced monitoring and diagnostics.
/*
resource "azurerm_monitor_diagnostic_setting" "vm_diag" {
  count                      = var.vm_count
  name                       = "diag-${var.vm_name}-${count.index}"
  # Points to each specific VM in the count
  target_resource_id         = azurerm_windows_virtual_machine.vm[count.index].id
  log_analytics_workspace_id = var.log_analytics_id

  # Monitoring VM Health
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
*/
