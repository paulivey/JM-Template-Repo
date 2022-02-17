provider "azurerm" {
  features {}
}

# Backend state
terraform {
  backend "azurerm" {
    resource_group_name  = "RG-TERRAFORM"
    storage_account_name = "iveyterraformbackend"
    container_name       = "terraform"
    key                  = "#{APP_NAME}#-policy.terraform.tfstate"
  }
}

# Set up Azure Policy assignment on the resource group
module "policy_assignment" {
  source = "git::https://github.com/iveylabs/JM-TF-Modules.git//modules/azure_policy_rg_assignment?ref=1.0.0"

  resource_group_name = "RG-${upper(var.environment)}-${upper(var.project)}-${upper(var.region_short)}-${upper(var.app_name)}-${var.app_suffix}"
  tag_country         = var.tag_country
  tag_environment     = var.tag_environment
  tag_window          = var.tag_window
  tag_sector          = var.tag_sector
  tag_app_name        = var.tag_app_name
  tag_cost_center     = var.tag_cost_center
  tag_app_owner       = var.tag_app_owner
  tag_classification  = var.tag_classification
  tag_class           = var.tag_class
}
