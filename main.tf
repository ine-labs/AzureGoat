terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.11.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
  }
}

provider "azurerm" {
  features {}
}


variable "resource_group" {
  default = "azuregoat_app"
}

variable "location" {
  type = string
  default = "eastus"
}
 

resource "azurerm_cosmosdb_account" "db" {
  name                = "ine-cosmos-db-data-${random_id.randomId.dec}"
  location            = "eastus"
  resource_group_name = var.resource_group
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  capabilities {
    name = "EnableServerless"
  }

  geo_location {
    location          = "eastus"
    failover_priority = 0
  }
}

resource "null_resource" "file_populate_data" {
  provisioner "local-exec" {
    command     = <<EOF
sed -i 's/AZURE_FUNCTION_URL/${azurerm_storage_account.storage_account.name}\.blob\.core\.windows\.net\/${azurerm_storage_container.storage_container_prod.name}/g' modules/module-1/resources/cosmosdb/blog-posts.json
python3 -m venv azure-goat-environment
source azure-goat-environment/bin/activate
pip3 install --pre azure-cosmos
python3 modules/module-1/resources/cosmosdb/create-table.py
EOF
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [azurerm_cosmosdb_account.db,azurerm_storage_account.storage_account,azurerm_storage_container.storage_container]
}




resource "azurerm_storage_account" "storage_account" {
  name = "appazgoat${random_id.randomId.dec}storage"
  resource_group_name = var.resource_group
  location = var.location
  account_tier = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = true

  blob_properties{
    cors_rule{
        allowed_headers = ["*"]
        allowed_methods = ["GET","HEAD","POST","PUT"]
        allowed_origins = ["*"]
        exposed_headers = ["*"]
        max_age_in_seconds = 3600
        }
    }
}

resource "azurerm_storage_container" "storage_container" {
    name = "appazgoat${random_id.randomId.dec}-storage-container"
    storage_account_name = azurerm_storage_account.storage_account.name
    container_access_type = "blob"
}

locals {
  now = timestamp()
  sasExpiry = timeadd(local.now, "240h")
  date_now = formatdate("YYYY-MM-DD", local.now)
  date_br = formatdate("YYYY-MM-DD", local.sasExpiry)
}
data "azurerm_storage_account_blob_container_sas" "storage_account_blob_container_sas" {
  connection_string = azurerm_storage_account.storage_account.primary_connection_string
  container_name    = azurerm_storage_container.storage_container.name
  start  = "${local.date_now}"
  expiry = "${local.date_br}"
  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = false
    list   = false
  }
}


resource "null_resource" "env_replace" {
  provisioner "local-exec" {
    command     = <<EOF
pwd
sed -i 's`AZ_DB_PRIMARYKEY_REPLACE`${azurerm_cosmosdb_account.db.primary_key}`' modules/module-1/resources/azure_function/data/local.settings.json
sed -i 's`AZ_DB_ENDPOINT_REPLACE`${azurerm_cosmosdb_account.db.endpoint}`' modules/module-1/resources/azure_function/data/local.settings.json
sed -i 's`CON_STR_REPLACE`${azurerm_storage_account.storage_account.primary_connection_string}`' modules/module-1/resources/azure_function/data/local.settings.json
sed -i 's`CONTAINER_NAME_REPLACE`${azurerm_storage_container.storage_container.name}`' modules/module-1/resources/azure_function/data/local.settings.json

EOF
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [azurerm_cosmosdb_account.db,azurerm_storage_account.storage_account,azurerm_storage_container.storage_container]
}


data "archive_file" "file_function_app" {
  type        = "zip"
  source_dir  = "modules/module-1/resources/azure_function/data"
  output_path = "modules/module-1/resources/azure_function/data/data-api.zip"
  depends_on = [
    null_resource.env_replace
  ]
}

resource "azurerm_storage_blob" "storage_blob" {
  name = "modules/module-1/resources/azure_function/data/data-api.zip"
  storage_account_name = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_container.name
  type = "Block"
  source = "modules/module-1/resources/azure_function/data/data-api.zip"
  depends_on = [data.archive_file.file_function_app]
}


resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "appazgoat${random_id.randomId.dec}-app-service-plan"
  resource_group_name = var.resource_group
  location            = var.location
  kind                = "FunctionApp"
  reserved            = true
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "function_app" {
  name                       = "appazgoat${random_id.randomId.dec}-function"
  resource_group_name        = var.resource_group
  location                   = var.location
  app_service_plan_id        = azurerm_app_service_plan.app_service_plan.id
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"    = "https://${azurerm_storage_account.storage_account.name}.blob.core.windows.net/${azurerm_storage_container.storage_container.name}/${azurerm_storage_blob.storage_blob.name}${data.azurerm_storage_account_blob_container_sas.storage_account_blob_container_sas.sas}",
    FUNCTIONS_WORKER_RUNTIME = "python",
    "JWT_SECRET" = "T2BYL6#]zc>Byuzu",
    "AZ_DB_ENDPOINT" = "${azurerm_cosmosdb_account.db.endpoint}",
    "AZ_DB_PRIMARYKEY" = "${azurerm_cosmosdb_account.db.primary_key}",
    "CON_STR" = "${azurerm_storage_account.storage_account.primary_connection_string}"
    "CONTAINER_NAME" = "${azurerm_storage_container.storage_container.name}"
  }
  os_type = "linux"
  site_config {
    linux_fx_version = "python|3.9"
    use_32_bit_worker_process = false
    cors {
      allowed_origins = ["*"]
    }
  }
  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  version                    = "~3"
  depends_on = [azurerm_cosmosdb_account.db,azurerm_storage_account.storage_account,null_resource.env_replace]
}


# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group_name = var.resource_group
  }

  byte_length = 3
}



# Storage Accounts Config
#################################################################################
locals {
  mime_types = {
    "css"  = "text/css"
    "html" = "text/html"
    "ico"  = "image/vnd.microsoft.icon"
    "js"   = "application/javascript"
    "json" = "application/json"
    "map"  = "application/json"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "svg"  = "image/svg+xml"
    "txt"  = "text/plain"
    "pub"  = "text/plain"
    "pem"  = "text/plain"
    "sh" = "text/x-shellscript"
  }
}


resource "azurerm_storage_container" "storage_container_prod" {
  name                  = "prod-appazgoat${random_id.randomId.dec}-storage-container"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "blob"
}


resource "azurerm_storage_container" "storage_container_dev" {
  name                  = "dev-appazgoat${random_id.randomId.dec}-storage-container"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "container"
}

resource "azurerm_storage_container" "storage_container_vm" {
  name                  = "vm-appazgoat${random_id.randomId.dec}-storage-container"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "container"
}



resource "null_resource" "file_replacement_upload" {
  provisioner "local-exec" {
    command     = <<EOF
pwd
sed -i 's/="\//="https:\/\/${azurerm_storage_account.storage_account.name}\.blob\.core\.windows\.net\/${azurerm_storage_container.storage_container_prod.name}\/webfiles\/build\//g' modules/module-1/resources/azure_function/react/webapp/index.html
sed -i 's/"\/static/"https:\/\/${azurerm_storage_account.storage_account.name}\.blob\.core\.windows\.net\/${azurerm_storage_container.storage_container_prod.name}\/webfiles\/build\/static/g' modules/module-1/resources/storage_account/webfiles/build/static/js/main.adc6b28e.js
sed -i 's/"\/static/"https:\/\/${azurerm_storage_account.storage_account.name}\.blob\.core\.windows\.net\/${azurerm_storage_container.storage_container_prod.name}\/webfiles\/build\/static/g' modules/module-1/resources/storage_account/webfiles/build/static/js/main.adc6b28e.js
sed -i 's/n.p+"static/"https:\/\/${azurerm_storage_account.storage_account.name}\.blob\.core\.windows\.net\/${azurerm_storage_container.storage_container_prod.name}\/webfiles\/build\/static/g' modules/module-1/resources/storage_account/webfiles/build/static/js/main.adc6b28e.js
sed -i "s,AZURE_FUNCTION_URL,https:\/\/${azurerm_function_app.function_app.default_hostname},g" modules/module-1/resources/storage_account/webfiles/build/static/js/main.adc6b28e.js
EOF 
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [data.azurerm_storage_account_blob_container_sas.storage_account_blob_container_sas,azurerm_storage_container.storage_container,azurerm_storage_account.storage_account]
}

resource "azurerm_storage_blob" "app_files_prod" {
  for_each               = fileset("./modules/module-1/resources/storage_account/", "**")
  name                   = each.value
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_container_prod.name
  content_type           = lookup(tomap(local.mime_types), element(split(".", each.value), length(split(".", each.value)) - 1))
  type                   = "Block"
  source                 = "./modules/module-1/resources/storage_account/${each.value}"
  depends_on = [null_resource.file_replacement_upload,azurerm_storage_container.storage_container_prod]
}

resource "azurerm_storage_blob" "app_files_dev" {
  for_each               = fileset("./modules/module-1/resources/storage_account/", "**")
  name                   = each.value
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_container_dev.name
  content_type           = lookup(tomap(local.mime_types), element(split(".", each.value), length(split(".", each.value)) - 1))
  type                   = "Block"
  source                 = "./modules/module-1/resources/storage_account/${each.value}"
  depends_on = [null_resource.file_replacement_upload,azurerm_storage_container.storage_container_dev]
}



resource "azurerm_storage_blob" "app_files_vm" {
  for_each               = fileset("./modules/module-1/resources/storage_account/", "**")
  name                   = each.value
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_container_vm.name
  content_type           = lookup(tomap(local.mime_types), element(split(".", each.value), length(split(".", each.value)) - 1))
  type                   = "Block"
  source                 = "./modules/module-1/resources/storage_account/${each.value}"
  depends_on = [null_resource.file_replacement_upload,azurerm_storage_container.storage_container_vm]
}




# VM Config
#################################################################################
# Security group
resource "azurerm_network_security_group" "net_sg" {
  name                = "SecGroupNet${random_id.randomId.dec}"
  location            = var.location
  resource_group_name = var.resource_group

  security_rule {
    name                       = "SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


# Virtual network
resource "azurerm_virtual_network" "vNet" {
  name                = "vNet${random_id.randomId.dec}"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group
}
resource "azurerm_subnet" "vNet_subnet" {
  name                 = "Subnet${random_id.randomId.dec}"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.vNet.name
  address_prefixes     = ["10.1.0.0/24"]
  depends_on = [
    azurerm_virtual_network.vNet
  ]
}

#public ip
resource "azurerm_public_ip" "VM_PublicIP" {
  name                    = "developerVMPublicIP${random_id.randomId.dec}"
  resource_group_name     = var.resource_group
  location                = var.location
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 4
  domain_name_label       = lower("developervm-${random_id.randomId.dec}")
  sku                     = "Basic"
}
data "azurerm_public_ip" "vm_ip" {
  name                = azurerm_public_ip.VM_PublicIP.name
  resource_group_name = var.resource_group
  depends_on          = [azurerm_virtual_machine.dev-vm]
}
#Network interface
resource "azurerm_network_interface" "net_int" {
  name                = "developerVMNetInt"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.vNet_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.VM_PublicIP.id
  }
  depends_on = [
    azurerm_network_security_group.net_sg,
    azurerm_public_ip.VM_PublicIP,
    azurerm_subnet.vNet_subnet
  ]
}

#Network Interface SG allocation
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.net_int.id
  network_security_group_id = azurerm_network_security_group.net_sg.id
}


#Virtual Machine
resource "azurerm_virtual_machine" "dev-vm" {

  name                  = "developerVM${random_id.randomId.dec}"
  location              = var.location
  resource_group_name   = var.resource_group
  network_interface_ids = [azurerm_network_interface.net_int.id]


  vm_size = "Standard_B1s"

  delete_os_disk_on_termination = true

  delete_data_disks_on_termination = true

  identity {
    type = "SystemAssigned"
  }
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "developerVMDisk"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "developerVM"
    admin_username = "azureuser"
    admin_password = "St0r95p@$sw0rd@1265463541"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  depends_on = [
    azurerm_network_interface.net_int
  ]

}

resource "azurerm_virtual_machine_extension" "test" {
  name                 = "vm-extension"
  virtual_machine_id   = azurerm_virtual_machine.dev-vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "script": "${base64encode(templatefile("modules/module-1/resources/vm/config.sh", {
          URL="${azurerm_storage_account.storage_account.name}.blob.core.windows.net/${azurerm_storage_container.storage_container_prod.name}"
        }))}"
    }
SETTINGS
depends_on = [null_resource.file_replacement_upload,azurerm_storage_blob.app_files_prod]
}

#Role Assignment

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "example" {
}

resource "azurerm_role_assignment" "az_role_assgn_vm" {
  scope              = "${data.azurerm_subscription.primary.id}/resourceGroups/${var.resource_group}"
  role_definition_name = "Contributor"
  principal_id       = azurerm_virtual_machine.dev-vm.identity.0.principal_id
}

resource "azurerm_role_assignment" "az_role_assgn_identity" {
  scope              = "${data.azurerm_subscription.primary.id}/resourceGroups/${var.resource_group}"
  role_definition_name = "Owner"
  principal_id       = azurerm_user_assigned_identity.user_id.principal_id
  depends_on = [
    azurerm_user_assigned_identity.user_id
  ]
}


resource "azurerm_user_assigned_identity" "user_id" {
  resource_group_name = var.resource_group
  location              = var.location

  name = "user-assigned-id${random_id.randomId.dec}"
}

resource "azurerm_automation_account" "dev_automation_account_test" {
  name                = "dev-automation-account-appazgoat${random_id.randomId.dec}"
  location              = var.location
  resource_group_name = var.resource_group
  sku_name            = "Basic"
    identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_id.id]
  }

  tags = {
    environment = "development"
  }
}

data "local_file" "runbook_file" {
  filename = "modules/module-1/resources/vm/listVM.ps1"
depends_on = [
  null_resource.clientid_replacement
]
}
resource "null_resource" "clientid_replacement" {
    provisioner "local-exec" {
    command     = <<EOF
sed -i 's/REPLACE_CLIENT_ID/${azurerm_user_assigned_identity.user_id.client_id}/g' modules/module-1/resources/vm/listVM.ps1
sed -i 's/REPLACE_RESOURCE_GROUP_NAME/${var.resource_group}/g' modules/module-1/resources/vm/listVM.ps1
EOF
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "azurerm_automation_runbook" "dev_automation_runbook" {
  name                    = "Get-AzureVM"
  location              = var.location
  resource_group_name     = var.resource_group
  automation_account_name = azurerm_automation_account.dev_automation_account_test.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "This is an example runbook"
  runbook_type            = "PowerShellWorkflow"
  content = data.local_file.runbook_file.content
}


###########################frontend########################################

data "archive_file" "file_function_app_front" {
  type        = "zip"
  source_dir  = "modules/module-1/resources/azure_function/react"
  output_path = "modules/module-1/resources/azure_function/react/func.zip"
  depends_on = [null_resource.file_replacement_upload]
}

resource "azurerm_storage_blob" "storage_blob_front" {
  name = "modules/module-1/resources/azure_function/react/func.zip"
  storage_account_name = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_container.name
  type = "Block"
  source = "modules/module-1/resources/azure_function/react/func.zip"
  depends_on = [data.archive_file.file_function_app_front,azurerm_storage_container.storage_container]
}


resource "azurerm_function_app" "function_app_front" {
  name                       = "appazgoat${random_id.randomId.dec}-function-app"
  resource_group_name        = var.resource_group
  location                   = var.location
  app_service_plan_id        = azurerm_app_service_plan.app_service_plan.id
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"    = "https://${azurerm_storage_account.storage_account.name}.blob.core.windows.net/${azurerm_storage_container.storage_container.name}/${azurerm_storage_blob.storage_blob_front.name}${data.azurerm_storage_account_blob_container_sas.storage_account_blob_container_sas.sas}",
    FUNCTIONS_WORKER_RUNTIME = "node",
    "AzureWebJobsDisableHomepage" = "true",
  }
  os_type = "linux"
  site_config {
    linux_fx_version = "node|12"
    use_32_bit_worker_process = false
  }
  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  version                    = "~3"
  depends_on = [null_resource.file_replacement_upload]
}

resource "null_resource" "file_replacement_vm_ip" {
  provisioner "local-exec" {
    command     = "sed -i 's/VM_IP_ADDR/${data.azurerm_public_ip.vm_ip.ip_address}/g' modules/module-1/resources/storage_account/shared/files/.ssh/config.txt"
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [azurerm_virtual_machine.dev-vm,data.azurerm_public_ip.vm_ip]
}
resource "azurerm_storage_blob" "config_update_prod" {
  name                   = "modules/module-1/resources/storage_account/shared/files/.ssh/config.txt"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_container_prod.name
  type                   = "Block"
  source                 = "modules/module-1/resources/storage_account/shared/files/.ssh/config.txt"
  depends_on = [null_resource.file_replacement_vm_ip]
}

resource "azurerm_storage_blob" "config_update_dev" {
  name                   = "modules/module-1/resources/storage_account/shared/files/.ssh/config.txt"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_container_dev.name
  type                   = "Block"
  source                 = "modules/module-1/resources/storage_account/shared/files/.ssh/config.txt"
  depends_on = [null_resource.file_replacement_vm_ip]
}

resource "azurerm_storage_blob" "config_update_vm" {
  name                   = "modules/module-1/resources/storage_account/shared/files/.ssh/config.txt"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_container_vm.name
  type                   = "Block"
  source                 = "modules/module-1/resources/storage_account/shared/files/.ssh/config.txt"
  depends_on = [null_resource.file_replacement_vm_ip]
}
  
output "Target_URL"{
  value = "https://${azurerm_function_app.function_app_front.name}.azurewebsites.net"
}
    
