module "tags" {
  source              = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.module.common-tags.git?ref=v1.0.1"
  name                = local.name
  billing_cost_center = var.billing_cost_center
  environment         = lower(var.environment)
  resource_contact    = var.resource_contact
  resource_purpose    = var.resource_purpose
  division            = lower(var.division)
  channel             = lower(var.channel)
  application         = var.cmdb_application
  project             = var.project
  additional_tags     = var.additional_tags
}

module "subnet_group_tags" {
  source              = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.module.common-tags.git?ref=v1.0.1"
  name                = local.subnet_group_name
  billing_cost_center = var.billing_cost_center
  environment         = lower(var.environment)
  resource_contact    = var.resource_contact
  resource_purpose    = var.resource_purpose
  division            = lower(var.division)
  channel             = lower(var.channel)
  application         = var.cmdb_application
  project             = var.project
  additional_tags     = var.additional_tags
}

module "replication_instance_tags" {
  source              = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.module.common-tags.git?ref=v1.0.1"
  name                = local.replication_instance_name
  billing_cost_center = var.billing_cost_center
  environment         = lower(var.environment)
  resource_contact    = var.resource_contact
  resource_purpose    = var.resource_purpose
  division            = lower(var.division)
  channel             = lower(var.channel)
  application         = var.cmdb_application
  project             = var.project
  additional_tags     = var.additional_tags
}

module "dms_certificate_tags" {
  source              = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.module.common-tags.git?ref=v1.0.1"
  name                = local.dms_certificate_name
  billing_cost_center = var.billing_cost_center
  environment         = lower(var.environment)
  resource_contact    = var.resource_contact
  resource_purpose    = var.resource_purpose
  division            = lower(var.division)
  channel             = lower(var.channel)
  application         = var.cmdb_application
  project             = var.project
  additional_tags     = var.additional_tags
}

module "replication_task_tags" {
  source              = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.module.common-tags.git?ref=v1.0.1"
  name                = local.replication_task_name
  billing_cost_center = var.billing_cost_center
  environment         = lower(var.environment)
  resource_contact    = var.resource_contact
  resource_purpose    = var.resource_purpose
  division            = lower(var.division)
  channel             = lower(var.channel)
  application         = var.cmdb_application
  project             = var.project
  additional_tags     = var.additional_tags
}

module "event_subscription_tags" {
  source              = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.module.common-tags.git?ref=v1.0.1"
  name                = local.event_subscription
  billing_cost_center = var.billing_cost_center
  environment         = lower(var.environment)
  resource_contact    = var.resource_contact
  resource_purpose    = var.resource_purpose
  division            = lower(var.division)
  channel             = lower(var.channel)
  application         = var.cmdb_application
  project             = var.project
  additional_tags     = var.additional_tags
}

module "src_endpoint_tags" {
  source              = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.module.common-tags.git?ref=v1.0.1"
  name                = local.src_endpoint
  billing_cost_center = var.billing_cost_center
  environment         = lower(var.environment)
  resource_contact    = var.resource_contact
  resource_purpose    = var.resource_purpose
  division            = lower(var.division)
  channel             = lower(var.channel)
  application         = var.cmdb_application
  project             = var.project
  additional_tags     = var.additional_tags
}

module "tgt_endpoint_tags" {
  source              = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.module.common-tags.git?ref=v1.0.1"
  name                = local.tgt_endpoint
  billing_cost_center = var.billing_cost_center
  environment         = lower(var.environment)
  resource_contact    = var.resource_contact
  resource_purpose    = var.resource_purpose
  division            = lower(var.division)
  channel             = lower(var.channel)
  application         = var.cmdb_application
  project             = var.project
  additional_tags     = var.additional_tags
}

module "tags" {
  source              = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.module.common-tags.git?ref=v1.0.1"
  name                = local.name
  billing_cost_center = var.billing_cost_center
  environment         = lower(var.environment)
  resource_contact    = var.resource_contact
  resource_purpose    = var.resource_purpose
  division            = lower(var.division)
  channel             = lower(var.channel)
  application         = var.cmdb_application
  project             = var.project
  additional_tags     = var.additional_tags
}

module "subnet_group_tags" {
  source              = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.module.common-tags.git?ref=v1.0.1"
  name                = local.subnet_group_name
  billing_cost_center = var.billing_cost_center
  environment         = lower(var.environment)
  resource_contact    = var.resource_contact
  resource_purpose    = var.resource_purpose
  division            = lower(var.division)
  channel             = lower(var.channel)
  application         = var.cmdb_application
  project             = var.project
  additional_tags     = var.additional_tags
}

module "replication_instance_tags" {
  source              = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.module.common-tags.git?ref=v1.0.1"
  name                = local.replication_instance_name
  billing_cost_center = var.billing_cost_center
  environment         = lower(var.environment)
  resource_contact    = var.resource_contact
  resource_purpose    = var.resource_purpose
  division            = lower(var.division)
  channel             = lower(var.channel)
  application         = var.cmdb_application
  project             = var.project
  additional_tags     = var.additional_tags
}

module "dms_certificate_tags" {
  source              = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.module.common-tags.git?ref=v1.0.1"
  name                = local.dms_certificate_name
  billing_cost_center = var.billing_cost_center
  environment         = lower(var.environment)
  resource_contact    = var.resource_contact
  resource_purpose    = var.resource_purpose
  division            = lower(var.division)
  channel             = lower(var.channel)
  application         = var.cmdb_application
  project             = var.project
  additional_tags     = var.additional_tags
}

module "replication_task_tags" {
  source              = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.module.common-tags.git?ref=v1.0.1"
  name                = local.replication_task_name
  billing_cost_center = var.billing_cost_center
  environment         = lower(var.environment)
  resource_contact    = var.resource_contact
  resource_purpose    = var.resource_purpose
  division            = lower(var.division)
  channel             = lower(var.channel)
  application         = var.cmdb_application
  project             = var.project
  additional_tags     = var.additional_tags
}

module "event_subscription_tags" {
  source              = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.module.common-tags.git?ref=v1.0.1"
  name                = local.event_subscription
  billing_cost_center = var.billing_cost_center
  environment         = lower(var.environment)
  resource_contact    = var.resource_contact
  resource_purpose    = var.resource_purpose
  division            = lower(var.division)
  channel             = lower(var.channel)
  application         = var.cmdb_application
  project             = var.project
  additional_tags     = var.additional_tags
}

module "src_endpoint_tags" {
  source              = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.module.common-tags.git?ref=v1.0.1"
  name                = local.src_endpoint
  billing_cost_center = var.billing_cost_center
  environment         = lower(var.environment)
  resource_contact    = var.resource_contact
  resource_purpose    = var.resource_purpose
  division            = lower(var.division)
  channel             = lower(var.channel)
  application         = var.cmdb_application
  project             = var.project
  additional_tags     = var.additional_tags
}

module "tgt_endpoint_tags" {
  source              = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.module.common-tags.git?ref=v1.0.1"
  name                = local.tgt_endpoint
  billing_cost_center = var.billing_cost_center
  environment         = lower(var.environment)
  resource_contact    = var.resource_contact
  resource_purpose    = var.resource_purpose
  division            = lower(var.division)
  channel             = lower(var.channel)
  application         = var.cmdb_application
  project             = var.project
  additional_tags     = var.additional_tags
}

