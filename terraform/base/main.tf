provider "azurerm" {
  features {}
}

# Backend state
terraform {
  backend "azurerm" {
    resource_group_name  = "RG-TERRAFORM"
    storage_account_name = "iveylabsterraformbackend"
    container_name       = "terraform"
    key                  = "#{APP_NAME}#-#{APP_ENVIRONMENT}#-base.terraform.tfstate"
  }
}

# Create new resource group
module "create_resource_group" {
  source = "git::https://github.com/iveylabs/JM-Infra-Central.git//modules/resource_group?ref=main"

  rg_name         = "RG-${upper(var.environment)}-${upper(var.project)}-${upper(var.region_short)}-${upper(var.app_name)}-${var.app_suffix}"
  location        = var.location
  owner_object_id = var.owner_object_id
    tags   = {
    "Country"             = "${upper(var.tag_country)}"
    "Environment"         = "${upper(var.tag_environment)}"
    "Maintenance Window"  = "${upper(var.tag_window)}"
    "Business Sector"     = "${upper(var.tag_sector)}"
    "Application Name"    = "${upper(var.app_name)}"
    "Cost Center"         = "${upper(var.tag_cost_center)}"
    "Application Owner"   = "${upper(var.tag_app_owner)}"
    "Data Classification" = "${upper(var.tag_classification)}"
    "Service Class"       = "${upper(var.tag_class)}"
  }
}

# Create app service web app + service plan
module "create_app" {
  source = "git::https://github.com/iveylabs/JM-Infra-Central.git//modules/web_app_linux?ref=main"

    depends_on = [
      module.create_resource_group
  ]


  # Input variables
  app_name     = var.app_name
  app_rg_name  = module.create_resource_group.rg_name
  asp_name     = "app-svcplan-${lower(var.project)}-${lower(var.region_short)}-${lower(var.app_name)}"
  tags         = module.create_resource_group.rg_tags
  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "1"
    "WEBSITES_CONTAINER_START_TIME_LIMIT" = "1800"
  }
}

# Enable private endpoint
module "enable_private_endpoint" {
  source = "git::https://github.com/iveylabs/JM-Infra-Central.git//modules/private_endpoint?ref=main"

  # Input variables
  pvt_endpoint_name = "PE-${upper(var.environment)}-${upper(var.project)}-${upper(var.region_short)}-${upper(var.app_name)}-${var.app_suffix}"
  app_name          = var.app_name
  resource_id       = module.create_app.web_app_id
  subresource_names = [ "sites" ]
  tags              = module.create_resource_group.rg_tags
}

# Enable vNet integration
module "enable_vnet_integration" {
  source = "git::https://github.com/iveylabs/JM-Infra-Central.git//modules/vnet_integration?ref=main"

  depends_on = [
    module.enable_private_endpoint
  ]

  # Input variables
  nsg_name                = "NSG-${upper(var.environment)}-${upper(var.project)}-VI-${upper(var.app_name)}-${upper(var.region_short)}-${var.app_suffix}"
  subnet_name             = "SNET-${upper(var.environment)}-${upper(var.project)}-VI-${upper(var.app_name)}-${upper(var.region_short)}-${var.app_suffix}"
  address_prefixes        = var.address_prefixes
  svc_delegation_name     = "Microsoft.Web/serverFarms"
  web_app_rg_name         = module.create_resource_group.rg_name
  web_app_name            = var.app_name
  tags                    = module.create_resource_group.rg_tags
}

# Create storage account
module "create_storage_account" {
  source = "git::https://github.com/iveylabs/JM-Infra-Central.git//modules/storage_account?ref=main"

  depends_on = [
    module.create_resource_group
  ]

  # Input variables
  sta_rg_name = module.create_resource_group.rg_name
  sta_name    = var.app_name
  tags        = module.create_resource_group.rg_tags
}

# Create storage container
module "create_storage_container" {
  source = "git::https://github.com/iveylabs/JM-Infra-Central.git//modules/storage_container?ref=main"

  depends_on = [
    module.create_storage_account
  ]

  # Input variables
  sta_name       = var.app_name
  container_name = "mycontainer"
}

# Create storage share
module "create_storage_share" {
  source = "git::https://github.com/iveylabs/JM-Infra-Central.git//modules/storage_share?ref=main"

  depends_on = [
    module.create_storage_account
  ]

  # Input variables
  sta_name   = var.app_name
  share_name = "myshare"
}
