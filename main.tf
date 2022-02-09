provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_lab" {
  name     = "my-resources-group-lab-06"
  location = "West Europe"
}

resource "null_resource" "run-pestertest"{

   depends_on = [module.linuxservers]
   connection {
       type = "ssh"
       user = "azureuser"
       private_key = file("~/.ssh/id_rsa")
       host = module.linuxservers.public_ip_dns_name[0]
   }
   provisioner "file" {
    source = "./scripts/setup-nginx.sh"
    destination = "/var/tmp/setup-nginx.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /var/tmp/setup-nginx.sh",
      "/var/tmp/setup-nginx.sh",
      "echo '==== Provisionner is on its way'"
    ]
  }
}
module "linuxservers" {
  source              = "Azure/compute/azurerm"
  resource_group_name = azurerm_resource_group.rg_lab.name
  vm_os_simple        = "UbuntuServer"
  public_ip_dns       = ["my-nginx-server-anhton7777"] // change to a unique name per datacenter region
  vnet_subnet_id      = module.network.vnet_subnets[0]
   
  depends_on = [azurerm_resource_group.rg_lab]
  


  vm_hostname                      = "mylinuxvm"
  nb_public_ip                     = 1
  remote_port                      = "22"
  nb_instances                     = 2
  vm_os_publisher                  = "Canonical"
  vm_os_offer                      = "UbuntuServer"
  vm_os_sku                        = "18.04-LTS"
  
  boot_diagnostics                 = true
  delete_os_disk_on_termination    = true
  nb_data_disk                     = 2
  data_disk_size_gb                = 20
  data_sa_type                     = "Standard_LRS"
  enable_ssh_key                   = true
  ssh_key_values                   = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDUGMciUOzYN9IqX2B9oeD/+cyK/Hv7xE8CGCJHU4WcV8MXqTdwZVPjxCHuwgfHro3fapb/2g+8pma2B7aNXSzIJzWdmJjSLIzoeeEOAiqoyBxek9B7jA1QeBfGSvb1cOR02TWpNl3KQib6rr7Qgt5uZVgzpVb0iRUq0BzOafNI+izRs0KxweWmkO4fbktQzeWYBuD2jaFXaEc5a56Dx9Lhpy4FMcDwxTwUo+jMzCMM0YVW0SJBs5c/d2ArmLWKRULzZpetsMOBjXR9pDLoS5o6GCs6G/NYPwOgn9+svrPRa66QqqsRsgc8ojWYDXsU4tZW3rcQmYAMub/Fb/QWam1slN4TxauuutyImJOKdyII7/oFqg03nuo2ND3ZXl13e9qAwNW/sz0Pf2I8zEguikdXhMfyJvaeTyVACKPn3YUt06KI9CjgktkmjCIJDMe8OMpgpy8NdWxjSx+aJaajFXvgWWY6BpdrPu2prE0rXbbEYsObA3HDqjJ3/0AB0y9aSQU= student@ROME3-3"]
  vm_size                          = "Standard_DS1_v2"
  delete_data_disks_on_termination = true


}
module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.rg_lab.name
  subnet_prefixes     = ["10.0.1.0/24"]
  subnet_names        = ["subnet1"]
  depends_on = [azurerm_resource_group.rg_lab]
}

