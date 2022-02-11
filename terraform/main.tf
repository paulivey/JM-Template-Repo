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
  #TODO: Set to GH repo, using tags/releases for versioning
  source = "git::https://github.com/iveylabs/JM-TF-Modules.git/modules/web_app_linux?ref=main"

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

# # Enable private endpoint
# module "enable_private_endpoint" {
#   # TODO: Set to GH repo, using tags/releases for versioning
#   source = "../modules/private_endpoint"

#   # Input variables
#   pvt_endpoint_name = "PE-${upper(var.environment)}-${upper(var.project)}-${upper(var.region_short)}-${upper(var.app_name)}-${var.app_suffix}"
#   app_name          = var.app_name
#   resource_id       = module.create_app.web_app_id
#   subresource_names = [ "sites" ]
# }

# # Enable vNet integration
# module "enable_vnet_integration" {
#   # TODO: Set to GH repo, using tags/releases for versioning
#   source = "../modules/vnet_integration"

#   depends_on = [
#     module.enable_private_endpoint
#   ]

#   # Input variables
#   nsg_name                = "NSG-${upper(var.environment)}-${upper(var.project)}-VI-${upper(var.app_name)}-${upper(var.region_short)}-${var.app_suffix}"
#   subnet_name             = "SNET-${upper(var.environment)}-${upper(var.project)}-VI-${upper(var.app_name)}-${upper(var.region_short)}-${var.app_suffix}"
#   address_prefixes        = ["10.0.2.0/26"]
#   svc_delegation_name     = "Microsoft.Web/serverFarms"
#   web_app_rg_name         = azurerm_resource_group.rg.name
#   web_app_name            = var.app_name
# }

# # Create storage account
# module "create_storage_account" {
#   # TODO: Set to GH repo, using tags/releases for versioning
#   source = "../modules/storage_account"

#   depends_on = [
#     azurerm_resource_group.rg
#   ]

#   # Input variables
#   sta_rg_name = azurerm_resource_group.rg.name
#   sta_name    = "${lower(var.app_name)}"
# }

# # Create storage container
# module "create_storage_container" {
#   # TODO: Set to GH repo, using tags/releases for versioning
#   source = "../modules/storage_container"

#   depends_on = [
#     module.create_storage_account
#   ]

#   # Input variables
#   sta_name       = "${lower(var.app_name)}"
#   container_name = "mycontainer"
# }

# # Create storage share
# module "create_storage_share" {
#   # TODO: Set to GH repo, using tags/releases for versioning
#   source = "../modules/storage_share"

#   depends_on = [
#     module.create_storage_account
#   ]

#   # Input variables
#   sta_name   = "${lower(var.app_name)}"
#   share_name = "myshare"
# }