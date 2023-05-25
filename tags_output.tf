output "commontags" {
  value = merge({
    Name              = var.name
    BillingCostCenter = var.billing_cost_center
    Environment       = var.environment
    ResourceContact   = var.resource_contact
    ResourcePurpose   = var.resource_purpose
    Division          = var.division
    TerraformManaged  = true
    Channel           = var.channel
    Application       = var.application
    Project           = var.project
    RTSInitiative     = var.project
    },
    var.additional_tags,
  )
}
