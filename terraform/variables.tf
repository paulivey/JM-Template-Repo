variable "app_name" {
    type    = string
}

variable "location" {
    type    = string
}

variable "environment"  {
    type    = string
}

variable "project"  {
    type    = string
}

variable "region_short"  {
    type    = string
}

variable "app_suffix"  {
    type    = string
}

variable "address_prefixes" {
    type    = list(string)
}

variable "policy_definition_id" {
    type    = string
}

variable "tag_country" {
    type    = string
}

variable "tag_environment" {
    type    = string
}

variable "tag_window" {
    type    = string
}

variable "tag_sector" {
    type    = string
}

variable "tag_app_name" {
    type    = string
}

variable "tag_cost_center" {
    type    = string
}

variable "tag_app_owner" {
    type    = string
}

variable "tag_classification" {
    type    = string
}

variable "tag_class" {
    type    = string
}
