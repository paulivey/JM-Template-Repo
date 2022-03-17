provider "azurerm" {
  features {}
}

# Backend state
terraform {
  backend "azurerm" {
    resource_group_name  = "RG-TERRAFORM"
    storage_account_name = "iveylabsterraformbackend"
    container_name       = "terraform"
    key                  = "#{APP_NAME}#-#{APP_ENVIRONMENT}#-policy.terraform.tfstate"
  }
}

# Set up Azure Policy assignment on the resource group
module "policy_assignment" {
  source = "git::https://github.com/iveylabs/JM-Infra-Central.git//modules/azure_policy_rg_assignment?ref=main"
  policy_definition_id = var.policy_definition_id
  resource_group_name  = "RG-${upper(var.environment)}-${upper(var.project)}-${upper(var.region_short)}-${upper(var.app_name)}-${var.app_suffix}"
  tag_country          = "${upper(var.tag_country)}"
  tag_environment      = "${upper(var.tag_environment)}"
  tag_window           = "${upper(var.tag_window)}"
  tag_sector           = "${upper(var.tag_sector)}"
  tag_app_name         = "${upper(var.app_name)}"
  tag_cost_center      = "${upper(var.tag_cost_center)}"
  tag_app_owner        = "${upper(var.tag_app_owner)}"
  tag_classification   = "${upper(var.tag_classification)}"
  tag_class            = "${upper(var.tag_class)}"
}
