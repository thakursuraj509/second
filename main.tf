#Replication subnet group
resource "aws_dms_replication_subnet_group" "ta_dms_subnet_grp" {
  count                                = var.create && var.create_subnet_group ? 1 : 0
  replication_subnet_group_description = local.subnet_group_description
  replication_subnet_group_id          = local.subnet_group_name
  subnet_ids                           = local.subnet_ids
  tags                                 = module.subnet_group_tags.commontags
}

#Replication instance
resource "aws_dms_replication_instance" "ta_replication_instance" {
  count                        = var.create && var.create_replication_instance ? 1 : 0
  allocated_storage            = var.allocated_storage
  allow_major_version_upgrade  = var.allow_major_version_upgrade
  apply_immediately            = var.apply_immediately
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  availability_zone            = var.multi_az ? null : var.availability_zone
  engine_version               = var.engine_version
  kms_key_arn                  = var.kms_key_arn
  multi_az                     = var.multi_az
  preferred_maintenance_window = var.preferred_maintenance_window
  publicly_accessible          = var.publicly_accessible
  replication_instance_class   = var.replication_instance_class
  replication_instance_id      = local.replication_instance_name
  replication_subnet_group_id  = length(var.replication_subnet_group_id) > 0 ? var.replication_subnet_group_id : aws_dms_replication_subnet_group.ta_dms_subnet_grp[0].id
  tags                         = module.replication_instance_tags.commontags
  vpc_security_group_ids       = local.security_groups
}

# DMS certificate
resource "aws_dms_certificate" "dms_certificate" {
  count           = var.create && var.create_dms_certificate ? 1 : 0
  certificate_id  = local.dms_certificate_name
  certificate_pem = var.certificate_pem
  tags = module.dms_certificate_tags.commontags
}

# DMS source endpoint
resource "aws_dms_endpoint" "ta_source_endpoint" {
  count                           = var.create && var.src_create_endpoint ? 1 : 0
  endpoint_id                     = local.src_endpoint
  endpoint_type                   = "source"
  engine_name                     = var.src_engine_name
  kms_key_arn                     = var.src_kms_key_arn
  extra_connection_attributes     = var.src_extra_connection_attributes
  password                        = var.src_password
  port                            = var.src_port
  certificate_arn                 = length(var.src_certificate_arn) > 0 ? var.src_certificate_arn : var.create_dms_certificate ? aws_dms_certificate.dms_certificate[0].certificate_arn : null
  database_name                   = local.src_database
  server_name                     = local.src_server
  ssl_mode                        = var.src_ssl_mode
  tags                            = module.src_endpoint_tags.commontags
  username                        = var.src_username

  dynamic kinesis_settings {
    for_each = var.src_engine_name == "kinesis" ? [1] : []
    content {
      include_control_details        = var.src_include_control_details
      include_null_and_empty         = var.src_include_null_and_empty
      include_partition_value        = var.src_include_partition_value
      include_table_alter_operations = var.src_include_table_alter_operations
      include_transaction_details    = var.src_include_transaction_details
      message_format                 = var.src_message_format
      partition_include_schema_table = var.src_partition_include_schema_table
      service_access_role_arn        = var.src_service_access_role_arn
      stream_arn                     = var.src_stream_arn
    }
  }
}

# DMS target endpoint
resource "aws_dms_endpoint" "ta_target_endpoint" {
  count                           = var.create && var.tgt_create_endpoint ? 1 : 0
  endpoint_id                     = local.tgt_endpoint
  endpoint_type                   = "target"
  engine_name                     = var.tgt_engine_name
  kms_key_arn                     = var.tgt_kms_key_arn
  extra_connection_attributes     = var.tgt_extra_connection_attributes
  password                        = var.tgt_password
  port                            = var.tgt_port
  certificate_arn                 = length(var.tgt_certificate_arn) > 0 ? var.tgt_certificate_arn : var.create_dms_certificate ? aws_dms_certificate.dms_certificate[0].certificate_arn : null
  database_name                   = local.tgt_database
  server_name                     = local.tgt_server
  ssl_mode                        = var.tgt_ssl_mode
  tags                            = module.tgt_endpoint_tags.commontags
  username                        = var.tgt_username

  dynamic kinesis_settings {
    for_each = var.tgt_engine_name == "kinesis" ? [1] : []
    content {
      include_control_details        = var.tgt_include_control_details
      include_null_and_empty         = var.tgt_include_null_and_empty
      include_partition_value        = var.tgt_include_partition_value
      include_table_alter_operations = var.tgt_include_table_alter_operations
      include_transaction_details    = var.tgt_include_transaction_details
      message_format                 = var.tgt_message_format
      partition_include_schema_table = var.tgt_partition_include_schema_table
      service_access_role_arn        = var.tgt_service_access_role_arn
      stream_arn                     = var.tgt_stream_arn
    }
  }
}

# Create a new replication task
resource "aws_dms_replication_task" "ta_replication_task" {
  count                     = var.create && var.create_replication_task ? 1 : 0
  cdc_start_time            = var.cdc_start_position == "" && var.cdc_start_time != null  ? var.cdc_start_time : null
  cdc_start_position        = var.cdc_start_time != null && var.cdc_start_position != null ?  null : var.cdc_start_position
  migration_type            = var.migration_type
  replication_instance_arn  = var.create_replication_instance ? aws_dms_replication_instance.ta_replication_instance[0].replication_instance_arn : var.replication_instance_arn
  replication_task_id       = local.replication_task_name
  replication_task_settings = var.replication_task_settings
  source_endpoint_arn       = var.src_create_endpoint ? aws_dms_endpoint.ta_source_endpoint[0].endpoint_arn : var.source_endpoint_arn
  table_mappings            = var.table_mappings
  tags                      = module.replication_task_tags.commontags
  target_endpoint_arn       = var.tgt_create_endpoint ? aws_dms_endpoint.ta_target_endpoint[0].endpoint_arn : var.target_endpoint_arn
}

#Create a new event subscription
resource "aws_dms_event_subscription" "ta_event_subscription" {
  count            = var.create && var.create_event_subscription ? 1 : 0
  enabled          = var.create_event_subscription
  event_categories = var.event_categories
  name             = local.event_subscription
  sns_topic_arn    = var.sns_topic_arn
  source_ids       = length(var.source_ids) > 0 ? var.source_ids : var.create_replication_task ? [aws_dms_replication_task.ta_replication_task[0].id] : []  
  source_type      = var.source_type
  tags             = module.event_subscription_tags.commontags
}