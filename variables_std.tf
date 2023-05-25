variable "account_number" {
  description = "AWS Account number to create the resources in."
  type        = string
}

variable "additional_tags" {
  description = "Additional tags to assign to the resources. Defaults to empty map."
  type        = map(string)
  default     = {}
}

variable "application" {
  description = "The name of the application the resources are for."
  type        = string
}

variable "billing_cost_center" {
  description = "Cost center for billing and reporting. Will be value of the tag `BillingCostCenter`. Defaults to `0701-TTA05000 Technology General Support`."
  type        = string
  default     = "0701-TTA05000 Technology General Support"
}

variable "channel" {
  description = "Transamerica Channel which owns the resources.  Will be value of the tag `Channel`."
  type        = string
}

variable "cmdb_application" {
  type        = string
  description = "This is the CMDB ID concatenated with a ':', and concatenated again with the CMDB Application name. Will be the value of the tag `Application`."
}

variable "department" {
  description = "Transamerica department which owns the resource."
  type        = string
}

variable "division" {
  description = "Division which owns the resources.  Will be value of the tag `Division`. Defaults to `transamerica`."
  type        = string
  default     = "transamerica"
}

variable "environment" {
  description = "Environment in (`dev`, `tst`, `mdl`, `prd`). Will be the value of the tag `Environment`."
  type        = string
}

variable "project" {
  description = "Associated Project (RTS number). Will be the value of both the `Project` and the `RTSInitiative` tags."
  type        = string
}

variable "region" {
  description = "Region everything is executed in. Defaults to `us-east-1`."
  default     = "us-east-1"
  type        = string
}

variable "resource_contact" {
  description = "Email address of team/user. Will be value of the tag `ResourceContact`."
  type        = string
}

variable "resource_purpose" {
  description = "Description of resource usage. Will be value of the tag `ResourcePurpose.`"
  type        = string
}

# Used by data
variable "environment_full" {
  type = object({
    DEV = string
    TST = string
    MDL = string
    PRD = string
  })
  default = {
    DEV = "Development"
    TST = "Test"
    MDL = "Model"
    PRD = "Production"
  }
}
