locals {
  subnet_group_description  = var.subnet_group_description == "" ? "${var.department}-${var.application}-${lower(var.environment)}" : var.subnet_group_description
  name                      = var.name == "" ? "${var.department}-${var.application}-${lower(var.environment)}" : lower(var.name)
  subnet_group_name         = var.subnet_group_name == "" ? local.name : var.subnet_group_name
  replication_instance_name = var.replication_instance_name == "" ? local.name : var.replication_instance_name
  dms_certificate_name      = var.dms_certificate_name == "" ? local.name : var.dms_certificate_name
  src_endpoint              = var.src_endpoint_name == "" ? "${var.department}-${var.application}-src-endpoint-${lower(var.environment)}" : var.src_endpoint_name
  tgt_endpoint              = var.tgt_endpoint_name == "" ? "${var.department}-${var.application}-tgt-endpoint-${lower(var.environment)}" : var.tgt_endpoint_name
  src_database              = var.src_database_name == "" ? local.src_endpoint : var.src_database_name
  src_server                = var.src_server_name == "" ? local.src_endpoint : var.src_server_name
  tgt_database              = var.tgt_database_name == "" ? local.tgt_endpoint : var.tgt_database_name
  tgt_server                = var.tgt_server_name == "" ? local.tgt_endpoint : var.tgt_server_name
  replication_task_name     = var.replication_task_name == "" ? local.name : var.replication_task_name
  event_subscription        = var.event_subscription == "" ? local.name : var.event_subscription
  security_groups = concat(
    var.allow_public ? [data.aws_security_group.AWS_Public_Services.id] : [],
    var.allow_cloudwatch ? [data.aws_security_group.AWS_CloudWatchLogs.id] : [],
    var.allow_internal ? [data.aws_security_group.Internal.id] : [],
    var.additional_security_group_ids
  )
  subnet_ids      = length(var.subnets) > 0 ? var.subnets : data.aws_subnets.private_subnet_ids.ids
}
