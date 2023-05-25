module "dms_horizon" {
  source                                = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.modules.dms.git"
  # tags
  account_number                        = var.account_number
  department                            = var.department 
  region                                = var.region
  billing_cost_center                   = var.billing_cost_center
  environment                           = var.environment 
  resource_contact                      = var.resource_contact
  resource_purpose                      = "TA Individual IDA AWS DMS Resource"
  division                              = var.division
  channel                               = "${var.division}.${var.channel}"
  cmdb_application                      = var.cmdb_application
  application                           = var.cmdb_application
  project                               = "RTS-99078"
  additional_tags                       = local.root_module_tags

  # Replication subnet group
  create_subnet_group                   = true
  subnet_group_description              = "dms datalake subnet group"
  subnet_group_name                     = "${var.department}-${var.application}-${var.environment}"
  subnets                               = var.subnets
  environment_full                      = var.__environment_full
  
  # Replication instance
  create_replication_instance           = true
  allocated_storage                     = 1000
  allow_major_version_upgrade           = true
  auto_minor_version_upgrade            = true
  apply_immediately                     = true
  multi_az                              = false
  availability_zone                     = "us-east-1a"
  engine_version                        = "3.4.5"
  kms_key_arn                           = "arn:aws:kms:${var.region}:${var.account_number}:key/${var.kms_key_arn}"
  preferred_maintenance_window          = "fri:04:54-fri:09:54"
  publicly_accessible                   = false
  replication_instance_class            = "dms.r5.2xlarge"
  replication_instance_name             = "${var.department}-${var.application}-${var.environment}-horizon"
  replication_subnet_group_id           = var.replication_subnet_group_id

  # DMS certificate
  create_dms_certificate                = false

  # DMS source endpoint
  src_create_endpoint                   = true
  src_endpoint_name                     = "${var.department}-${var.application}-${var.environment}-sc-horizon"
  src_engine_name                       = "oracle"
  src_kms_key_arn                       = "arn:aws:kms:${var.region}:${var.account_number}:key/${var.kms_key_arn}"
  src_extra_connection_attributes       = "useLogMinerReader=N;useBfile=Y;addSupplementalLogging=Y;readaheadblocks=10000"
  src_password                          = local.db_creds.horizon.password
  src_port                              = var.port_horizon
  src_certificate_arn                   = "arn:aws:dms:${var.region}:${var.account_number}:cert:${var.src_certificate_arn}"
  src_database_name                     = var.database_name_sc_horizon
  src_server_name                       = var.src_server_name
  src_ssl_mode                          = "verify-ca"
  src_username                          = local.db_creds.horizon.username

  # DMS target endpoint
  tgt_create_endpoint                   = true
  tgt_endpoint_name                     = "${var.department}-${var.application}-${var.environment}-kinesis-tg-horizon"
  tgt_engine_name                       = "kinesis"
  tgt_kms_key_arn                       = var.tgt_kms_key_arn
  tgt_extra_connection_attributes       = "includeOpForFullLoad=true"
  tgt_password                          = var.tgt_password
  tgt_port                              = var.tgt_port
  tgt_certificate_arn                   = var.tgt_certificate_arn        
  tgt_database_name                     = var.tgt_database_name
  tgt_server_name                       = var.tgt_server_name
  tgt_ssl_mode                          = var.tgt_ssl_mode
  tgt_username                          = var.tgt_username
  tgt_include_control_details           = var.tgt_include_control_details
  tgt_include_null_and_empty            = var.tgt_include_null_and_empty
  tgt_include_partition_value           = var.tgt_include_partition_value
  tgt_include_table_alter_operations    = var.tgt_include_table_alter_operations
  tgt_include_transaction_details       = var.tgt_include_transaction_details
  tgt_message_format                    = "json-unformatted"
  tgt_partition_include_schema_table    = var.tgt_partition_include_schema_table
  tgt_service_access_role_arn           = "arn:aws:iam::${var.account_number}:role/${var.department}-${var.application}-${var.environment}-kinesis-s3-dms-horizon"
  tgt_stream_arn                        = module.kinesis_horizon_stream.stream_arn

  # Create a new replication task
  create_replication_task               = true
  cdc_start_position                    = var.cdc_start_position
  cdc_start_time                        = var.cdc_start_time
  migration_type                        = "full-load-and-cdc"
  replication_task_name                 = "${var.department}-${var.application}-${var.environment}-kinesis-horizon"
  replication_task_settings             = <<EOT
   {
    "Logging":
    {
      "EnableLogging": true,
      "LogComponents": [
        {
          "Id": "SOURCE_UNLOAD",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        },
        {
          "Id": "SOURCE_CAPTURE",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        },
        {
          "Id": "TARGET_LOAD",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        },
        {
          "Id": "TARGET_APPLY",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        },
        {
          "Id": "TASK_MANAGER",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        }
      ]
    },
    "FullLoadSettings": 
      {
        "TargetTablePrepMode": "DO_NOTHING",
        "CommitRate": 50000
      },
    "TargetMetadata": 
      {
        "LobMaxSize": 10729,
        "ParallelLoadThreads": 16,
        "ParallelLoadQueuesPerThread": 128,
        "ParallelLoadBufferSize": 500,
        "ParallelApplyThreads": 32,
        "ParallelApplyBufferSize": 1000,
        "ParallelApplyQueuesPerThread": 64
      },
    "StreamBufferSettings": 
      {
        "StreamBufferCount": 6,
        "StreamBufferSizeInMB": 16,
        "CtrlStreamBufferSizeInMB": 8
      },
    "ChangeProcessingTuning":
      {
        "MemoryLimitTotal": 2048,
        "MemoryKeepTime": 120
      }
  }
  EOT
  table_mappings                        = <<EOT
    {
        "rules": [
            {
                "rule-type": "selection",
                "rule-id": "1",
                "rule-name": "1",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "CURR_AGT_CONTR"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "2",
                "rule-name": "2",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "CURR_AGT_CONTR"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'HORIZON_CURR_AGT_CONTR'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "3",
                "rule-name": "3",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "REPRESENTATIVE"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "4",
                "rule-name": "4",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "REPRESENTATIVE"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'HORIZON_REPRESENTATIVE'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
			{
                "rule-type": "selection",
                "rule-id": "5",
                "rule-name": "5",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "AGT_TYPE"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "6",
                "rule-name": "6",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "AGT_TYPE"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'HORIZON_AGT_TYPE'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
			{
                "rule-type": "selection",
                "rule-id": "7",
                "rule-name": "7",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "POL_HIER"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "8",
                "rule-name": "8",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "POL_HIER"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'HORIZON_POL_HIER'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
			{
                "rule-type": "selection",
                "rule-id": "9",
                "rule-name": "9",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "CORRESPONDENCE_RULES"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "10",
                "rule-name": "10",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "CORRESPONDENCE_RULES"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'HORIZON_CORRESPONDENCE_RULES'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
			{
                "rule-type": "selection",
                "rule-id": "11",
                "rule-name": "11",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "POL_MSTR"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "12",
                "rule-name": "12",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "POL_MSTR "
                },
                "value": "SCHEMA_TABLE",
                "expression": "'HORIZON_POL_MSTR'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
			{
                "rule-type": "selection",
                "rule-id": "13",
                "rule-name": "13",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "AGT_STATUS"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "14",
                "rule-name": "14",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "AGT_STATUS "
                },
                "value": "SCHEMA_TABLE",
                "expression": "'HORIZON_AGT_STATUS'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "15",
                "rule-name": "15",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "REP_LIC"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "16",
                "rule-name": "16",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "REP_LIC "
                },
                "value": "SCHEMA_TABLE",
                "expression": "'HORIZON_REP_LIC'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "17",
                "rule-name": "17",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "REP_APPT"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "18",
                "rule-name": "18",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "REP_APPT "
                },
                "value": "SCHEMA_TABLE",
                "expression": "'HORIZON_REP_APPT'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "19",
                "rule-name": "19",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "LIC_LOB"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "20",
                "rule-name": "20",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "LIC_LOB "
                },
                "value": "SCHEMA_TABLE",
                "expression": "'HORIZON_LIC_LOB'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "21",
                "rule-name": "21",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "STAT_CO"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "22",
                "rule-name": "22",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "STAT_CO "
                },
                "value": "SCHEMA_TABLE",
                "expression": "'HORIZON_STAT_CO'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "23",
                "rule-name": "23",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "EMAIL"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "24",
                "rule-name": "24",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "EMAIL "
                },
                "value": "SCHEMA_TABLE",
                "expression": "'HORIZON_EMAIL'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "25",
                "rule-name": "25",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "MKT_ORG"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "26",
                "rule-name": "26",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "MKT_ORG "
                },
                "value": "SCHEMA_TABLE",
                "expression": "'HORIZON_MKT_ORG'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "27",
                "rule-name": "27",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "REP_ADDR"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "28",
                "rule-name": "28",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "REP_ADDR "
                },
                "value": "SCHEMA_TABLE",
                "expression": "'HORIZON_REP_ADDR'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "29",
                "rule-name": "29",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "REP_PHONE"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "30",
                "rule-name": "30",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "HORIZON",
                    "table-name": "REP_PHONE "
                },
                "value": "SCHEMA_TABLE",
                "expression": "'HORIZON_REP_ADDR'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            }
        ]
    }
  EOT

  # Create a new event subscription
  create_event_subscription             = true
  event_categories                      = ["failure"]
  event_subscription                    = "${var.department}-${var.environment}-dms-replication-instance-event-subscription"
  sns_topic_arn                         = module.sns_event_topic.sns_topic_arn
  source_ids                            = ["${var.department}-${var.dl_application}-${var.environment}-pds", "${var.department}-${var.application}-${var.environment}-horizon", "${var.department}-${var.application}-${var.environment}-phd"]
  source_type                           = "replication-instance"
}

module "dms_phd" {
  source                                = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.modules.dms.git"
  # tags
  account_number                        = var.account_number
  department                            = var.department 
  region                                = var.region
  billing_cost_center                   = var.billing_cost_center
  environment                           = var.environment 
  resource_contact                      = var.resource_contact
  resource_purpose                      = "TA Individual IDA AWS DMS Resource"
  division                              = var.division
  channel                               = "${var.division}.${var.channel}"
  cmdb_application                      = var.cmdb_application
  application                           = var.cmdb_application
  project                               = "RTS-99078"
  additional_tags                       = local.root_module_tags

  # Replication subnet group
  create_subnet_group                   = false
  environment_full                      = var.__environment_full

  # Replication instance
  create_replication_instance           = true
  allocated_storage                     = 1000
  allow_major_version_upgrade           = true
  auto_minor_version_upgrade            = true
  apply_immediately                     = true
  multi_az                              = false
  availability_zone                     = "us-east-1a"
  engine_version                        = "3.4.5"
  kms_key_arn                           = "arn:aws:kms:${var.region}:${var.account_number}:key/${var.kms_key_arn}"
  preferred_maintenance_window          = "fri:04:54-fri:09:54"
  publicly_accessible                   = false
  replication_instance_class            = "dms.r5.2xlarge"
  replication_instance_name             = "${var.department}-${var.application}-${var.environment}-phd"
  replication_subnet_group_id           = "${var.department}-${var.application}-${var.environment}"

  # DMS certificate
  create_dms_certificate                = false

  # DMS source endpoint
  src_create_endpoint                   = true
  src_endpoint_name                     = "${var.department}-${var.application}-${var.environment}-sc-phd"
  src_engine_name                       = "oracle"
  src_kms_key_arn                       = "arn:aws:kms:${var.region}:${var.account_number}:key/${var.kms_key_arn}"
  src_extra_connection_attributes       = "useLogMinerReader=N;useBfile=Y;addSupplementalLogging=Y;readaheadblocks=500000"
  src_password                          = local.db_creds.phd.password
  src_port                              = var.port_phd
  src_certificate_arn                   = "arn:aws:dms:${var.region}:${var.account_number}:cert:${var.src_certificate_arn}"
  src_database_name                     = var.database_name_sc_phd
  src_server_name                       = var.src_server_name
  src_ssl_mode                          = "verify-ca"
  src_username                          = local.db_creds.phd.username

  # DMS target endpoint
  tgt_create_endpoint                   = true
  tgt_endpoint_name                     = "${var.department}-${var.application}-${var.environment}-kinesis-tg-phd"
  tgt_engine_name                       = "kinesis"
  tgt_kms_key_arn                       = var.tgt_kms_key_arn
  tgt_extra_connection_attributes       = "includeOpForFullLoad=true"
  tgt_password                          = var.tgt_password
  tgt_port                              = var.tgt_port
  tgt_certificate_arn                   = var.tgt_certificate_arn 
  tgt_database_name                     = var.tgt_database_name
  tgt_server_name                       = var.tgt_server_name
  tgt_ssl_mode                          = var.tgt_ssl_mode
  tgt_username                          = var.tgt_username
  tgt_include_control_details           = var.tgt_include_control_details
  tgt_include_null_and_empty            = var.tgt_include_null_and_empty
  tgt_include_partition_value           = var.tgt_include_partition_value
  tgt_include_table_alter_operations    = var.tgt_include_table_alter_operations
  tgt_include_transaction_details       = var.tgt_include_transaction_details
  tgt_message_format                    = "json-unformatted"
  tgt_partition_include_schema_table    = var.tgt_partition_include_schema_table
  tgt_service_access_role_arn           = "arn:aws:iam::${var.account_number}:role/${var.department}-${var.application}-${var.environment}-kinesis-s3-dms-horizon"
  tgt_stream_arn                        = module.kinesis_phd_stream.stream_arn

  # Create a new replication task
  create_replication_task               = true
  cdc_start_position                    = var.cdc_start_position
  cdc_start_time                        = var.cdc_start_time
  migration_type                        = "full-load-and-cdc"
  replication_task_name                 = "${var.department}-${var.application}-${var.environment}-kinesis-phd"
  table_mappings                        = <<EOT
    {
        "rules": [
            {
                "rule-type": "selection",
                "rule-id": "1",
                "rule-name": "1",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "2",
                "rule-name": "2",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PLCY'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "3",
                "rule-name": "3",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_ACTY"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "4",
                "rule-name": "4",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_ACTY"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PLCY_ACTY'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "5",
                "rule-name": "5",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_STS"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "6",
                "rule-name": "6",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_STS"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PLCY_STS'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "7",
                "rule-name": "7",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_COV"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "8",
                "rule-name": "8",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_COV"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PLCY_COV'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "9",
                "rule-name": "9",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PARTY"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "10",
                "rule-name": "10",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PARTY"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PARTY'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "11",
                "rule-name": "11",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_COV_PARTY_RTG"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "12",
                "rule-name": "12",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_COV_PARTY_RTG"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PLCY_COV_PARTY_RTG'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "13",
                "rule-name": "13",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_BILG"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "14",
                "rule-name": "14",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_BILG"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PLCY_BILG'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "15",
                "rule-name": "15",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_DPST"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "16",
                "rule-name": "16",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_DPST"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PLCY_DPST'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "17",
                "rule-name": "17",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_FUNDS_ON_DPST"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "18",
                "rule-name": "18",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_FUNDS_ON_DPST"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PLCY_FUNDS_ON_DPST'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "19",
                "rule-name": "19",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "BILG_GRP"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "20",
                "rule-name": "20",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "BILG_GRP"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_BILG_GRP'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "21",
                "rule-name": "21",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_FUND"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "22",
                "rule-name": "22",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_FUND"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PLCY_FUND'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "23",
                "rule-name": "23",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "FUND"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "24",
                "rule-name": "24",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "FUND"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_FUND'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "25",
                "rule-name": "25",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_COV_PARTY"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "26",
                "rule-name": "26",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_COV_PARTY"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PLCY_COV_PARTY'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "27",
                "rule-name": "27",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_PARTY"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "28",
                "rule-name": "28",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_PARTY"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PLCY_PARTY'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "29",
                "rule-name": "29",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PARTY_ADR"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "30",
                "rule-name": "30",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PARTY_ADR"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PARTY_ADR'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "31",
                "rule-name": "31",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PARTY_PHN"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "32",
                "rule-name": "32",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PARTY_PHN"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PARTY_PHN'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "33",
                "rule-name": "33",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PARTY_EMAIL"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "34",
                "rule-name": "34",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PARTY_EMAIL"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PARTY_EMAIL'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "35",
                "rule-name": "35",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PARTY_PRDCR"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "36",
                "rule-name": "36",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PARTY_PRDCR"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PARTY_PRDCR'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "37",
                "rule-name": "37",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PRDT"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "38",
                "rule-name": "38",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PRDT"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PRDT'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "39",
                "rule-name": "39",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_HIER"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "40",
                "rule-name": "40",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PLCY_HIER"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PLCY_HIER'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "41",
                "rule-name": "41",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "STS_CD_LU"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "42",
                "rule-name": "42",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "STS_CD_LU"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_STS_CD_LU'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "43",
                "rule-name": "43",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "ST_TC_LU"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "44",
                "rule-name": "44",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "ST_TC_LU"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_ST_TC_LU'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "45",
                "rule-name": "45",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "GNDR_LU"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "46",
                "rule-name": "46",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "GNDR_LU"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_GNDR_LU'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "47",
                "rule-name": "47",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PARTY_REL_LU"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "48",
                "rule-name": "48",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PARTY_REL_LU"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PARTY_REL_LU'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "49",
                "rule-name": "49",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PARTY_TYPE_LU"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "50",
                "rule-name": "50",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PARTY_TYPE_LU"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PARTY_TYPE_LU'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "51",
                "rule-name": "51",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "RISK_CLASS_LU"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "52",
                "rule-name": "52",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "RISK_CLASS_LU"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_RISK_CLASS_LU'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "53",
                "rule-name": "53",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PYMT_MTHD_LU"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "54",
                "rule-name": "54",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PYMT_MTHD_LU"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PYMT_MTHD_LU'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "55",
                "rule-name": "55",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PYMT_MODE_LU"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "56",
                "rule-name": "56",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "PYMT_MODE_LU"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_PYMT_MODE_LU'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "57",
                "rule-name": "57",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "DTH_BNFT_LU"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "58",
                "rule-name": "58",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "DTH_BNFT_LU"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_DTH_BNFT_LU'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "59",
                "rule-name": "59",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "FORM_FUND"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "60",
                "rule-name": "60",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLH",
                    "table-name": "FORM_FUND"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLH_FORM_FUND'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            }
        ]
    }
  EOT
  replication_task_settings             = <<EOT
   {
    "Logging":
    {
      "EnableLogging": true,
      "LogComponents": [
        {
          "Id": "SOURCE_UNLOAD",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        },
        {
          "Id": "SOURCE_CAPTURE",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        },
        {
          "Id": "TARGET_LOAD",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        },
        {
          "Id": "TARGET_APPLY",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        },
        {
          "Id": "TASK_MANAGER",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        }
      ]
    },
    "FullLoadSettings": 
      {
        "TargetTablePrepMode": "DO_NOTHING",
        "CommitRate": 50000
      },
    "TargetMetadata": 
      {
        "LobMaxSize": 10729,
        "ParallelLoadThreads": 16,
        "ParallelLoadQueuesPerThread": 128,
        "ParallelLoadBufferSize": 500,
        "ParallelApplyThreads": 32,
        "ParallelApplyBufferSize": 1000,
        "ParallelApplyQueuesPerThread": 64
      },
    "StreamBufferSettings": 
      {
        "StreamBufferCount": 6,
        "StreamBufferSizeInMB": 16,
        "CtrlStreamBufferSizeInMB": 8
      },
    "ChangeProcessingTuning":
      {
        "MemoryLimitTotal": 2048,
        "MemoryKeepTime": 120
      }
  }
  EOT

  # Create a new event subscription
  create_event_subscription             = var.create_event_subscription
}

module "dms_pds" {
  source                                = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.modules.dms.git"
  # tags
  account_number                        = var.account_number
  department                            = var.department 
  region                                = var.region
  billing_cost_center                   = var.billing_cost_center
  environment                           = var.environment 
  resource_contact                      = var.resource_contact
  resource_purpose                      = "TA Individual IDA AWS DMS Resource"
  division                              = var.division
  channel                               = "${var.division}.${var.channel}"
  cmdb_application                      = var.cmdb_application
  application                           = var.cmdb_application
  project                               = "RTS-99078"
  additional_tags                       = local.root_module_tags

  # Replication subnet group
  create_subnet_group                   = true
  subnet_group_description              = "dms datalake subnet group"
  subnet_group_name                     = "${var.department}-${var.dl_application}-${var.environment}"
  subnets                               = var.subnets
  environment_full                      = var.__environment_full
  
  # Replication instance
  create_replication_instance           = true
  allocated_storage                     = 1000
  allow_major_version_upgrade           = true
  auto_minor_version_upgrade            = true
  apply_immediately                     = true
  multi_az                              = false
  availability_zone                     = "us-east-1a"
  engine_version                        = "3.4.5"
  kms_key_arn                           = "arn:aws:kms:${var.region}:${var.account_number}:key/${var.kms_key_arn}"
  preferred_maintenance_window          = "fri:04:54-fri:09:54"
  publicly_accessible                   = false
  replication_instance_class            = "dms.r5.2xlarge"
  replication_instance_name             = "${var.department}-${var.dl_application}-${var.environment}-pds"
  replication_subnet_group_id           = var.replication_subnet_group_id

  # DMS certificate
  create_dms_certificate                = false

  # DMS source endpoint
  src_create_endpoint                   = true
  src_endpoint_name                     = "${var.department}-${var.dl_application}-${var.environment}-pds-sc"
  src_engine_name                       = "oracle"
  src_kms_key_arn                       = "arn:aws:kms:${var.region}:${var.account_number}:key/${var.kms_key_arn}"
  src_extra_connection_attributes       = "useLogMinerReader=N;useBfile=Y;addSupplementalLogging=Y;readaheadblocks=10000"
  src_password                          = local.db_creds.pds.password
  src_port                              = var.port_pds
  src_certificate_arn                   = "arn:aws:dms:${var.region}:${var.account_number}:cert:${var.src_certificate_arn}"
  src_database_name                     = var.database_name_sc_pds
  src_server_name                       = var.src_server_name
  src_ssl_mode                          = "verify-ca"
  src_username                          = local.db_creds.pds.username

  # DMS target endpoint
  tgt_create_endpoint                   = true
  tgt_endpoint_name                     = "${var.department}-${var.dl_application}-${var.environment}-kinesis-tg"
  tgt_engine_name                       = "kinesis"
  tgt_kms_key_arn                       = var.tgt_kms_key_arn
  tgt_extra_connection_attributes       = var.tgt_extra_connection_attributes
  tgt_password                          = var.tgt_password
  tgt_port                              = var.tgt_port
  tgt_certificate_arn                   = var.tgt_certificate_arn 
  tgt_database_name                     = var.tgt_database_name
  tgt_server_name                       = var.tgt_server_name
  tgt_ssl_mode                          = var.tgt_ssl_mode
  tgt_username                          = var.tgt_username
  tgt_include_control_details           = var.tgt_include_control_details
  tgt_include_null_and_empty            = var.tgt_include_null_and_empty
  tgt_include_partition_value           = var.tgt_include_partition_value
  tgt_include_table_alter_operations    = var.tgt_include_table_alter_operations
  tgt_include_transaction_details       = var.tgt_include_transaction_details
  tgt_message_format                    = "json-unformatted"
  tgt_partition_include_schema_table    = var.tgt_partition_include_schema_table
  tgt_service_access_role_arn           = "arn:aws:iam::${var.account_number}:role/${var.department}-${var.dl_application}-${var.environment}-kinesis-s3-dms"
  tgt_stream_arn                        = module.kinesis_pds_stream.stream_arn

  # Create a new replication task
  create_replication_task               = true
  cdc_start_position                    = var.cdc_start_position
  cdc_start_time                        = var.cdc_start_time
  migration_type                        = "full-load-and-cdc"
  replication_task_name                 = "${var.department}-${var.dl_application}-${var.environment}-pds-kinesis"
  table_mappings                        = <<EOT
    {
        "rules": [
            {
                "rule-type": "selection",
                "rule-id": "3",
                "rule-name": "3",
                "object-locator": {
                    "schema-name": "AFP_POLL",
                    "table-name": "PLCY"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "4",
                "rule-name": "4",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLL",
                    "table-name": "PLCY"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLL_PLCY'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "17",
                "rule-name": "17",
                "object-locator": {
                    "schema-name": "AFP_REFD_MSTR",
                    "table-name": "REFD_PARTY_REL_LU"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "18",
                "rule-name": "18",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_REFD_MSTR",
                    "table-name": "REFD_PARTY_REL_LU"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_REFD_MSTR_REFD_PARTY_REL_LU'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "19",
                "rule-name": "19",
                "object-locator": {
                    "schema-name": "AFP_REFD_MSTR",
                    "table-name": "REFD_PARTY_TYPE_LU"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "20",
                "rule-name": "20",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_REFD_MSTR",
                    "table-name": "REFD_PARTY_TYPE_LU"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_REFD_MSTR_REFD_PARTY_TYPE_LU'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "30",
                "rule-name": "30",
                "object-locator": {
                    "schema-name": "AFP_REFD_MSTR",
                    "table-name": "REFD_PLCY_STS_CD_LU"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "31",
                "rule-name": "31",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_REFD_MSTR",
                    "table-name": "REFD_PLCY_STS_CD_LU"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_REFD_MSTR_REFD_PLCY_STS_CD_LU'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "32",
                "rule-name": "32",
                "object-locator": {
                    "schema-name": "AFP_REFD_MSTR",
                    "table-name": "REFD_RQMT_CD_LU"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "33",
                "rule-name": "33",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_REFD_MSTR",
                    "table-name": "REFD_RQMT_CD_LU"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_REFD_MSTR_REFD_RQMT_CD_LU'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "34",
                "rule-name": "34",
                "object-locator": {
                    "schema-name": "AFP_REFD_MSTR",
                    "table-name": "REFD_RQMT_STS_LU"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "35",
                "rule-name": "35",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_REFD_MSTR",
                    "table-name": "REFD_RQMT_STS_LU"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_REFD_MSTR_REFD_RQMT_STS_LU'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "36",
                "rule-name": "36",
                "object-locator": {
                    "schema-name": "AFP_REFD_MSTR",
                    "table-name": "REFD_ST_LU"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "37",
                "rule-name": "37",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_REFD_MSTR",
                    "table-name": "REFD_ST_LU"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_REFD_MSTR_REFD_ST_LU'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "38",
                "rule-name": "38",
                "object-locator": {
                    "schema-name": "AFP_REFD_MSTR",
                    "table-name": "REFD_UW_USER_LU"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "39",
                "rule-name": "39",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_REFD_MSTR",
                    "table-name": "REFD_UW_USER_LU"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_REFD_MSTR_REFD_UW_USER_LU'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "40",
                "rule-name": "40",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_ST_LU_MVIEW"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "41",
                "rule-name": "41",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_ST_LU_MVIEW"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_REFD_REFD_ST_LU_MVIEW'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "42",
                "rule-name": "42",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_RQMT_STS_LU_MVIEW"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "43",
                "rule-name": "43",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_RQMT_STS_LU_MVIEW"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_REFD_REFD_RQMT_STS_LU_MVIEW'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "44",
                "rule-name": "44",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_RQMT_CD_LU_MVIEW"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "45",
                "rule-name": "45",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_RQMT_CD_LU_MVIEW"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_REFD_REFD_RQMT_CD_LU_MVIEW'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "46",
                "rule-name": "46",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_PARTY_TYPE_LU_MVIEW"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "47",
                "rule-name": "47",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_PARTY_TYPE_LU_MVIEW"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_REFD_REFD_PARTY_TYPE_LU_MVIEW'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "48",
                "rule-name": "48",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_PARTY_REL_LU_MVIEW"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "49",
                "rule-name": "49",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_PARTY_REL_LU_MVIEW"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_REFD_REFD_PARTY_REL_LU_MVIEW'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "50",
                "rule-name": "50",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_PYMT_MTHD_LU_MVIEW"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "51",
                "rule-name": "51",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_PYMT_MTHD_LU_MVIEW"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_REFD_REFD_PYMT_MTHD_LU_MVIEW'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "52",
                "rule-name": "52",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_PYMT_MODE_LU_MVIEW"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "53",
                "rule-name": "53",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_PYMT_MODE_LU_MVIEW"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_REFD_REFD_PYMT_MODE_LU_MVIEW'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "54",
                "rule-name": "54",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_CO_MVIEW"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "55",
                "rule-name": "55",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_CO_MVIEW"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_REFD_REFD_CO_MVIEW'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "56",
                "rule-name": "56",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_PLCY_STS_LU_MVIEW"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "57",
                "rule-name": "57",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_PLCY_STS_LU_MVIEW"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_REFD_REFD_PLCY_STS_LU_MVIEW'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "58",
                "rule-name": "58",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_PRDCR_HIER_LU_MVIEW"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "59",
                "rule-name": "59",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_PRDCR_HIER_LU_MVIEW"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_REFD_REFD_PRDCR_HIER_LU_MVIEW'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "60",
                "rule-name": "60",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_PRDT_TYPE_CD_LU_MVIEW"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "61",
                "rule-name": "61",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_PRDT_TYPE_CD_LU_MVIEW"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_REFD_REFD_PRDT_TYPE_CD_LU_MVIEW'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "62",
                "rule-name": "62",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_UW_USER_LU_MVIEW"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "63",
                "rule-name": "63",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_UW_USER_LU_MVIEW"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_REFD_REFD_UW_USER_LU_MVIEW'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "64",
                "rule-name": "64",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_APPL_TYPE_LU_MVIEW"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "65",
                "rule-name": "65",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_REFD",
                    "table-name": "REFD_APPL_TYPE_LU_MVIEW"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_REFD_REFD_APPL_TYPE_LU_MVIEW'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "68",
                "rule-name": "68",
                "object-locator": {
                    "schema-name": "AFP_POLL",
                    "table-name": "PLCY_HIER"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "69",
                "rule-name": "69",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLL",
                    "table-name": "PLCY_HIER"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLL_PLCY_HIER'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "72",
                "rule-name": "72",
                "object-locator": {
                    "schema-name": "AFP_POLL",
                    "table-name": "PLCY_CLOB"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "73",
                "rule-name": "73",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLL",
                    "table-name": "PLCY_CLOB"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLL_PLCY'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            }
        ]
    }
  EOT
  replication_task_settings             = <<EOT
   {
    "Logging":
    {
      "EnableLogging": true,
      "LogComponents": [
        {
          "Id": "SOURCE_UNLOAD",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        },
        {
          "Id": "SOURCE_CAPTURE",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        },
        {
          "Id": "TARGET_LOAD",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        },
        {
          "Id": "TARGET_APPLY",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        },
        {
          "Id": "TASK_MANAGER",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        }
      ]
    },
    "FullLoadSettings": 
      {
        "TargetTablePrepMode": "DO_NOTHING",
        "CommitRate": 50000
      },
    "TargetMetadata": 
      {
        "LobMaxSize": 10729,
        "ParallelLoadThreads": 16,
        "ParallelLoadQueuesPerThread": 128,
        "ParallelLoadBufferSize": 500,
        "ParallelApplyThreads": 32,
        "ParallelApplyBufferSize": 1000,
        "ParallelApplyQueuesPerThread": 64
      },
    "StreamBufferSettings": 
      {
        "StreamBufferCount": 6,
        "StreamBufferSizeInMB": 16,
        "CtrlStreamBufferSizeInMB": 8
      },
    "ChangeProcessingTuning":
      {
        "MemoryLimitTotal": 2048,
        "MemoryKeepTime": 120
      }
  }
  EOT

  # Create a new event subscription
  create_event_subscription             = true
  event_categories                      = ["failure"]
  event_subscription                    = "${var.department}-${var.environment}-dms-replication-task-event-subscription"
  sns_topic_arn                         = module.sns_event_topic.sns_topic_arn
  source_ids                            = ["${var.department}-${var.application}-${var.environment}-kinesis-horizon", "${var.department}-${var.dl_application}-${var.environment}-pds-kinesis", "${var.department}-${var.application}-${var.environment}-kinesis-phd"]
  source_type                           = "replication-task"
}

# SNS Topic and Subscriptions
module "sns_event_topic" {
  source                                = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.modules.sns.git"           
  account_number                        = var.account_number
  department                            = var.department
  name                                  = "${var.department}-${var.environment}-dms-event-subscription-sns"
  sns_subscriptions                     = var.sns_subscriptions
  billing_cost_center                   = var.billing_cost_center
  cmdb_application                      = var.cmdb_application
  environment                           = lower(var.environment)
  resource_contact                      = lower(var.resource_contact)
  resource_purpose                      = "TA Individual IDA Amazon SNS Resource"
  division                              = lower(var.division)
  channel                               = "${var.division}.${var.channel}"
  application                           = var.cmdb_application
  project                               = var.project
  additional_tags                       = local.root_module_tags
}

/*
resource "aws_dms_endpoint" "s3_ep_tg_pds" {
  endpoint_id                 = "${var.department}-${var.dl_application}-${var.environment}-s3-tg"
  endpoint_type               = "target"
  engine_name                 = "s3"
  extra_connection_attributes = "addColumnName=true;bucketFolder=PDS;bucketName=${var.bucket_name_landing};compressionType=NONE;datePartitionEnabled=false;includeOpForFullLoad=true;dataFormat=parquet;parquetVersion=PARQUET_2_0;timestampColumnName=CREATE_TIMESTAMP"
  s3_settings {
    service_access_role_arn   = "arn:aws:iam::${var.account_number}:role/${var.department}-${var.dl_application}-${var.environment}-kinesis-s3-dms"
    bucket_name               = var.bucket_name_landing
    bucket_folder             = "PDS"
  }
  tags                        = module.s3_ep_tg_pds_tags.commontags
}
*/

/*
# Kinesis replication task PDS PP
resource "aws_dms_replication_task" "kinesis_rt_pp_pds" {
  migration_type            = "full-load-and-cdc"
  replication_instance_arn  = aws_dms_replication_instance.datalake_replication_instance_pds.replication_instance_arn
  replication_task_id       = "${var.department}-${var.dl_application}-${var.environment}-pds-kinesis-pp"
  source_endpoint_arn       = aws_dms_endpoint.ep_sc_pds.endpoint_arn
  table_mappings            = <<EOT
    {
        "rules": [
            {
                "rule-type": "selection",
                "rule-id": "1",
                "rule-name": "1",
                "object-locator": {
                    "schema-name": "AFP_POLL",
                    "table-name": "PARTY"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "2",
                "rule-name": "2",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLL",
                    "table-name": "PARTY"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLL_PARTY'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "9",
                "rule-name": "9",
                "object-locator": {
                    "schema-name": "AFP_POLL",
                    "table-name": "PLCY_HIER"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "10",
                "rule-name": "10",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLL",
                    "table-name": "PLCY_HIER"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLL_PLCY_HIER'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            },
            {
                "rule-type": "selection",
                "rule-id": "13",
                "rule-name": "13",
                "object-locator": {
                    "schema-name": "AFP_POLL",
                    "table-name": "PLCY_PARTY"
                },
                "rule-action": "include"
            },
            {
                "rule-type": "transformation",
                "rule-id": "14",
                "rule-name": "14",
                "rule-action": "add-column",
                "rule-target": "column",
                "object-locator": {
                    "schema-name": "AFP_POLL",
                    "table-name": "PLCY_PARTY"
                },
                "value": "SCHEMA_TABLE",
                "expression": "'AFP_POLL_PLCY_PARTY'",
                "data-type": {
                    "type": "string",
                    "length": 60
                }
            }
        ]
    }
  EOT
  replication_task_settings = <<EOT
   {
    "Logging":
    {
      "EnableLogging": true,
      "LogComponents": [
        {
          "Id": "SOURCE_UNLOAD",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        },
        {
          "Id": "SOURCE_CAPTURE",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        },
        {
          "Id": "TARGET_LOAD",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        },
        {
          "Id": "TARGET_APPLY",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        },
        {
          "Id": "TASK_MANAGER",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        }
      ]
    },
    "FullLoadSettings": 
      {
        "TargetTablePrepMode": "DO_NOTHING",
        "CommitRate": 50000
      },
    "TargetMetadata": 
      {
        "LobMaxSize": 10729,
        "ParallelLoadThreads": 16,
        "ParallelLoadQueuesPerThread": 128,
        "ParallelLoadBufferSize": 500,
        "ParallelApplyThreads": 32,
        "ParallelApplyBufferSize": 1000,
        "ParallelApplyQueuesPerThread": 64
      },
    "StreamBufferSettings": 
      {
        "StreamBufferCount": 6,
        "StreamBufferSizeInMB": 16,
        "CtrlStreamBufferSizeInMB": 8
      },
    "ChangeProcessingTuning":
      {
        "MemoryLimitTotal": 2048,
        "MemoryKeepTime": 120
      }
  }
  EOT

  lifecycle {
    ignore_changes = [
      replication_task_settings
    ]
  }

  tags                      = module.kinesis_rt_pp_pds_tags.commontags
  target_endpoint_arn       = aws_dms_endpoint.kinesis_ep_tg_pds.endpoint_arn
}
*/

/*
# PDS S3 replication task
resource "aws_dms_replication_task" "s3_rt_pds" {
  migration_type            = "full-load-and-cdc"
  replication_instance_arn  = aws_dms_replication_instance.datalake_replication_instance_pds.replication_instance_arn
  replication_task_id       = "${var.department}-${var.dl_application}-${var.environment}-pds-s3"
  source_endpoint_arn       = aws_dms_endpoint.ep_sc_pds.endpoint_arn
  table_mappings            = <<EOT
  {
    "rules": [
        {
             "rule-type": "selection",
             "rule-id": "1",
             "rule-name": "1",
             "rule-action": "include",
             "object-locator": {
                 "schema-name": "AFP_POLL",
                 "table-name": "%"
             }
        },
        {
             "rule-type": "selection",
             "rule-id": "2",
             "rule-name": "2",
             "rule-action": "include",
             "object-locator": {
                 "schema-name": "AFP_REFD",
                 "table-name": "%"
             }
        },
        {
            "rule-type": "selection",
            "rule-id": "3",
            "rule-name": "3",
            "rule-action": "include",
            "object-locator": {
                "schema-name": "AFP_REFD_MSTR",
                "table-name": "%"
            }
        }
      ]
  }
  EOT
  replication_task_settings = <<EOT
   {
    "Logging":
    {
      "EnableLogging": true,
      "LogComponents": [
        {
          "Id": "SOURCE_UNLOAD",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        },
        {
          "Id": "SOURCE_CAPTURE",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        },
        {
          "Id": "TARGET_LOAD",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        },
        {
          "Id": "TARGET_APPLY",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        },
        {
          "Id": "TASK_MANAGER",
          "Severity": "LOGGER_SEVERITY_DEFAULT"
        }
      ]
    },
    "FullLoadSettings": 
      {
        "TargetTablePrepMode": "DROP_AND_CREATE",
        "CommitRate": 50000
      },
    "TargetMetadata": 
      {
        "LobMaxSize": 10729
      }
  }
  EOT

  lifecycle {
    ignore_changes = [
      replication_task_settings
    ]
  }

  tags                      = module.s3_rt_pds_tags.commontags

  target_endpoint_arn       = aws_dms_endpoint.s3_ep_tg_pds.endpoint_arn
}
*/

/*
module "s3_ep_tg_pds_tags" {
  source              = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.module.common-tags.git?ref=v1.0.1"
  name                = "${var.department}-${var.dl_application}-${var.environment}-s3-tg"
  billing_cost_center = var.billing_cost_center
  environment         = lower(var.environment)
  resource_contact    = lower(var.resource_contact)
  resource_purpose    = "TA Individual IDA AWS DMS Target S3 Endpoint Resource"
  division            = lower(var.division)
  channel             = "${var.division}.${var.channel}"
  application         = var.cmdb_application
  project             = var.project
  additional_tags     = local.root_module_tags
}
*/

/*
module "kinesis_rt_pp_pds_tags" {
  source              = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.module.common-tags.git?ref=v1.0.1"
  name                = "${var.department}-${var.dl_application}-${var.environment}-pds-kinesis-pp"
  billing_cost_center = var.billing_cost_center
  environment         = lower(var.environment)
  resource_contact    = lower(var.resource_contact)
  resource_purpose    = "TA Individual IDA AWS DMS PDS PP Database Migration Task Resource"
  division            = lower(var.division)
  channel             = "${var.division}.${var.channel}"
  application         = var.cmdb_application
  project             = var.project
  additional_tags     = local.root_module_tags
}
*/

/*
module "s3_rt_pds_tags" {
  source              = "git::http://bitbucket.us.aegon.com/scm/tacloudmodule/transamerica.cloud.module.common-tags.git?ref=v1.0.1"
  name                = "${var.department}-${var.dl_application}-${var.environment}-pds-s3"
  billing_cost_center = var.billing_cost_center
  environment         = lower(var.environment)
  resource_contact    = lower(var.resource_contact)
  resource_purpose    = "TA Individual IDA AWS DMS PDS S3 Database Migration Task Resource"
  division            = lower(var.division)
  channel             = "${var.division}.${var.channel}"
  application         = var.cmdb_application
  project             = var.project
  additional_tags     = local.root_module_tags
}
*/
