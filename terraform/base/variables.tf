variable "owner_object_id" {
    type    = string
}

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

variable "tags" {
    type    = map(string)
}
