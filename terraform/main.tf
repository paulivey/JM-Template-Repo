provider "azurerm" {
  features {}
}

# Backend state
terraform {
  backend "azurerm" {
    resource_group_name  = "RG-TERRAFORM"
    storage_account_name = "iveyterraformbackend"
    container_name       = "terraform"
    key                  = "green-testing.terraform.tfstate"
  }
}

# Create new resource group
resource "azurerm_resource_group" "rg" {
  name     = "RG-${upper(var.environment)}-${upper(var.project)}-${upper(var.region_short)}-${upper(var.app_name)}-${var.app_suffix}"
  location = var.location
}

# Create app service web app + service plan
module "create_app" {
  source = "git::https://github.com/iveylabs/JM-TF-Modules.git//modules/web_app_linux?ref=main"

  # Make sure the resource group exists first
  depends_on = [
    azurerm_resource_group.rg
  ]

  # Input variables
  app_name     = var.app_name
  app_rg_name  = "RG-${upper(var.environment)}-${upper(var.project)}-${upper(var.region_short)}-${upper(var.app_name)}-${var.app_suffix}"
  asp_name     = "app-svcplan-${lower(var.project)}-${lower(var.region_short)}-${lower(var.app_name)}"
  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "1"
    "WEBSITES_CONTAINER_START_TIME_LIMIT" = "1800"
  }
}

# Enable private endpoint
module "enable_private_endpoint" {
  source = "git::https://github.com/iveylabs/JM-TF-Modules.git//modules/private_endpoint?ref=main"

  # Input variables
  pvt_endpoint_name = "PE-${upper(var.environment)}-${upper(var.project)}-${upper(var.region_short)}-${upper(var.app_name)}-${var.app_suffix}"
  app_name          = var.app_name
  resource_id       = module.create_app.web_app_id
  subresource_names = [ "sites" ]
}

# Enable vNet integration
module "enable_vnet_integration" {
  source = "git::https://github.com/iveylabs/JM-TF-Modules.git//modules/vnet_integration?ref=main"

  depends_on = [
    module.enable_private_endpoint
  ]

  # Input variables
  nsg_name                = "NSG-${upper(var.environment)}-${upper(var.project)}-VI-${upper(var.app_name)}-${upper(var.region_short)}-${var.app_suffix}"
  subnet_name             = "SNET-${upper(var.environment)}-${upper(var.project)}-VI-${upper(var.app_name)}-${upper(var.region_short)}-${var.app_suffix}"
  address_prefixes        = ["10.1.0.64/26"]
  svc_delegation_name     = "Microsoft.Web/serverFarms"
  web_app_rg_name         = azurerm_resource_group.rg.name
  web_app_name            = var.app_name
}

# Create storage account
module "create_storage_account" {
  source = "git::https://github.com/iveylabs/JM-TF-Modules.git//modules/storage_account?ref=main"

  depends_on = [
    azurerm_resource_group.rg
  ]

  # Input variables
  sta_rg_name = azurerm_resource_group.rg.name
  sta_name    = "${lower(var.app_name)}"
}

# Create storage container
module "create_storage_container" {
  source = "git::https://github.com/iveylabs/JM-TF-Modules.git//modules/storage_container?ref=main"

  depends_on = [
    module.create_storage_account
  ]

  # Input variables
  sta_name       = "${lower(var.app_name)}"
  container_name = "mycontainer"
}

# Create storage share
module "create_storage_share" {
  source = "git::https://github.com/iveylabs/JM-TF-Modules.git//modules/storage_share?ref=main"

  depends_on = [
    module.create_storage_account
  ]

  # Input variables
  sta_name   = "${lower(var.app_name)}"
  share_name = "myshare"
}