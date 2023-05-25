variable "name" {
  description = "Provide resource name"
  type        = string
}

variable "billing_cost_center" {
  description = "provide a cost center for billing reporting (tag based on cloud custodian)"
  type        = string
}

variable "environment" {
  description = "dtap environment (DEV/TST/MDL/ACC/PRD)"
  type        = string
}

variable "resource_contact" {
  description = "provide an email for contacting (tag based on cloud custodian)"
  type        = string
}

variable "resource_purpose" {
  description = "provide a discription of what your using this for (tag based on cloud custodian)"
  type        = string
}

variable "division" {
  description = "Division responsible for instance (tag based on cloud custodian)"
  type        = string
}

variable "channel" {
  description = "Channel associated with this build"
  type        = string
}

variable "application" {
  description = "Application name Tag "
  type        = string
}

variable "project" {
  description = "Associated Project. Will populate both the `Project` and the `RTSInitiative` tags."
  type        = string
}

variable "additional_tags" {
  type = map(string)
  description = "Additional tags to add to the ASG. All will be propagated at launch."
  default     = {}
}
