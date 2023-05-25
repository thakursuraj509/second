variable "specific_vpc" {
  description = "Name of VPC"
  type        = string
  default = ""
}

variable "allow_public" {
  description = "Whether or not to attach the `Public` security group to the compute. Defaults to `true`."
  type        = bool
  default     = true
}

variable "allow_cloudwatch" {
  description = "Whether or not to attach the `CloudWatch` security group to the compute. Defaults to `true`."
  type        = bool
  default     = true
}

variable "allow_internal" {
  description = "Whether or not to attach the `Internal` security group to the compute. Defaults to `true`."
  type        = bool
  default     = true
}

variable "additional_security_group_ids" {
  type        = list(string)
  description = "A list of EC2 additional security group that are to be associated"
  default     = []
}

variable "subnets" {
  description = "List of subnet IDs."
  type        = list(string)
  default     = []
}

variable "subnet_group_description" {
  description = "The description for the subnet group."
  type        = string
  default     = ""
}

variable "name" {
  description = "The name for the resources in the module. This value is stored as a lowercase string."
  type        = string
  default     = ""
}

variable "create" {
  description = "Whether to create resource in this module"
  type        = bool
  default     = true
}

variable "allocated_storage" {
  description = "The amount of storage (in gigabytes) to be initially allocated for the replication instance."
  type        = number
  default     = 50
}

variable "allow_major_version_upgrade" {
  description = "Indicates that major version upgrades are allowed."
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the replication instance during the maintenance window."
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Indicates whether the changes should be applied immediately or during the next maintenance window. Only used when updating an existing resource."
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Specifies if the replication instance is a multi-az deployment."
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "The EC2 Availability Zone that the replication instance will be created in."
  type        = string
  default     = ""
}

variable "engine_version" {
  description = "The EC2 Availability Zone that the replication instance will be created in."
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "The Amazon Resource Name (ARN) for the KMS key that will be used to encrypt the connection parameters."
  type        = string
  default     = ""
}

variable "preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur, in Universal Coordinated Time (UTC)."
  type        = string
  default     = ""
}

variable "publicly_accessible" {
  description = "Specifies the accessibility options for the replication instance.Defaults to fasle"
  type        = bool
  default     = false
}

variable "replication_instance_class" {
  description = "The compute and memory capacity of the replication instance as specified by the replication instance class."
  type        = string
  default     = ""
}

variable "replication_subnet_group_id" {
  description = "The Subnet Group ID of the replication instance."
  type        = string
  default     = ""
}

variable "create_subnet_group" {
  description = "Whether to create dms subnet group"
  type        = bool
  default     = false
}

variable "create_replication_instance" {
  description = "Whether to create replication instance"
  type        = bool
  default     = false
}

variable "create_dms_certificate" {
  description = "Whether to create dms certificate"
  type        = bool
  default     = false
}

variable "src_create_endpoint" {
  description = "Whether to create source endpoint"
  type        = bool
  default     = false
}

variable "tgt_create_endpoint" {
  description = "Whether to create target endpoint"
  type        = bool
  default     = false
}

variable "create_replication_task" {
  description = "Whether to create replication task"
  type        = bool
  default     = false
}

variable "create_event_subscription" {
  description = "Whether to create event subscription"
  type        = bool
  default     = false
}

variable "replication_instance_name" {
  description = "Name of the replication instance"
  type        = string
  default     = ""
}

variable "subnet_group_name" {
  description = "Name of subnet group"
  type        = string
  default     = ""
}

#Source endpoint variables

variable "src_engine_name" {
  description = "Type of engine for the endpoint."
  type        = string
  default     = ""
}

variable "src_kms_key_arn" {
  description = "ARN for the KMS key that will be used to encrypt the connection parameters."
  type        = string
  default     = ""
}

variable "src_extra_connection_attributes" {
  description = "Additional attributes associated with the connection."
  type        = string
  default     = ""
}

variable "src_password" {
  description = "Password to be used to login to the endpoint database."
  type        = string
  default     = ""
}

variable "src_port" {
  description = "Port used by the endpoint database."
  type        = number
  default     = 3306
}

variable "src_certificate_arn" {
  description = "ARN for the source endpoint certificate."
  type        = string
  default     = ""
}

variable "dms_certificate_name" {
  description = "Name of the certificate to be created"
  type        = string
  default     = ""
}

variable "src_secrets_manager_access_role_arn" {
  description = "ARN of the IAM role that specifies AWS DMS as the trusted entity and has the required permissions to access the value in SecretsManagerSecret."
  type        = string
  default     = ""
}

variable "src_secrets_manager_arn" {
  description = "Full ARN, partial ARN, or friendly name of the SecretsManagerSecret that contains the endpoint connection details."
  type        = string
  default     = ""
}

variable "src_ssl_mode" {
  description = "SSL mode to use for the connection. Valid values are none, require, verify-ca, verify-full"
  type        = string
  default     = "none"
}

variable "src_username" {
  description = "User name to be used to login to the endpoint database."
  type        = string
  default     = ""
}

variable "src_include_control_details" {
  description = "Shows detailed control information for table definition, column definition, and table and column changes in the Kinesis message output. Default is false"
  type        = bool
  default     = false
}

variable "src_include_null_and_empty" {
  description = "Include NULL and empty columns in the target. Default is false."
  type        = bool
  default     = false
}

variable "src_include_partition_value" {
  description = "Shows the partition value within the Kinesis message output, unless the partition type is schema-table-type. Default is false."
  type        = bool
  default     = false
}

variable "src_include_table_alter_operations" {
  description = "Includes any data definition language (DDL) operations that change the table in the control data. Default is false."
  type        = bool
  default     = false
}

variable "src_include_transaction_details" {
  description = "Provides detailed transaction information from the source database. Default is false."
  type        = bool
  default     = false
}

variable "src_message_format" {
  description = "Output format for the records created. Default is json."
  type        = string
  default     = "json"
}

variable "src_partition_include_schema_table" {
  description = "Prefixes schema and table names to partition values, when the partition type is primary-key-type. Default is false."
  type        = bool
  default     = false
}

variable "src_service_access_role_arn" {
  description = "ARN of the IAM Role with permissions to write to the Kinesis data stream."
  type        = string
  default     = ""
}

variable "src_stream_arn" {
  description = "ARN of the Kinesis data stream."
  type        = string
  default     = ""
}

variable "src_endpoint_name" {
  description = "Name of source endpoint"
  type        = string
  default     = ""
}

variable "src_database_name" {
  description = "Name of source database"
  type        = string
  default     = ""
}

variable "src_server_name" {
  description = "Name of source server"
  type        = string
  default     = ""
}

#Target endpoint variables
variable "tgt_engine_name" {
  description = "Type of engine for the endpoint."
  type        = string
  default     = ""
}

variable "tgt_kms_key_arn" {
  description = "ARN for the KMS key that will be used to encrypt the connection parameters."
  type        = string
  default     = ""
}

variable "tgt_extra_connection_attributes" {
  description = "Additional attributes associated with the connection."
  type        = string
  default     = ""
}

variable "tgt_password" {
  description = "Password to be used to login to the endpoint database."
  type        = string
  default     = ""
}

variable "tgt_port" {
  description = "Port used by the endpoint database."
  type        = number
  default     = 3306
}

variable "tgt_certificate_arn" {
  description = "ARN for the target endpoint certificate."
  type        = string
  default     = ""
}

variable "tgt_secrets_manager_access_role_arn" {
  description = "ARN of the IAM role that specifies AWS DMS as the trusted entity and has the required permissions to access the value in SecretsManagerSecret."
  type        = string
  default     = ""
}

variable "tgt_secrets_manager_arn" {
  description = "Full ARN, partial ARN, or friendly name of the SecretsManagerSecret that contains the endpoint connection details."
  type        = string
  default     = ""
}

variable "tgt_ssl_mode" {
  description = "SSL mode to use for the connection. Valid values are none, require, verify-ca, verify-full"
  type        = string
  default     = "none"
}

variable "tgt_username" {
  description = "User name to be used to login to the endpoint database."
  type        = string
  default     = ""
}

variable "tgt_include_control_details" {
  description = "Shows detailed control information for table definition, column definition, and table and column changes in the Kinesis message output. Default is false"
  type        = bool
  default     = false
}

variable "tgt_include_null_and_empty" {
  description = "Include NULL and empty columns in the target. Default is false."
  type        = bool
  default     = false
}

variable "tgt_include_partition_value" {
  description = "Shows the partition value within the Kinesis message output, unless the partition type is schema-table-type. Default is false."
  type        = bool
  default     = false
}

variable "tgt_include_table_alter_operations" {
  description = "Includes any data definition language (DDL) operations that change the table in the control data. Default is false."
  type        = bool
  default     = false
}

variable "tgt_include_transaction_details" {
  description = "Provides detailed transaction information from the source database. Default is false."
  type        = bool
  default     = false
}

variable "tgt_message_format" {
  description = "Output format for the records created. Default is json."
  type        = string
  default     = "json"
}

variable "tgt_partition_include_schema_table" {
  description = "Prefixes schema and table names to partition values, when the partition type is primary-key-type. Default is false."
  type        = bool
  default     = false
}

variable "tgt_service_access_role_arn" {
  description = "ARN of the IAM Role with permissions to write to the Kinesis data stream."
  type        = string
  default     = ""
}

variable "tgt_stream_arn" {
  description = "ARN of the Kinesis data stream."
  type        = string
  default     = ""
}

variable "tgt_endpoint_name" {
  description = "Name of target endpoint"
  type        = string
  default     = ""
}

variable "tgt_database_name" {
  description = "Name of target database"
  type        = string
  default     = ""
}

variable "tgt_server_name" {
  description = "Name of target server"
  type        = string
  default     = ""
}

#Replication task variables
variable "cdc_start_position" {
  description = "Indicates when you want a change data capture (CDC) operation to start. The value can be in date, checkpoint, or LSN/SCN format depending on the source engine. For more information, see Determining a CDC native start point."
  type        = string
  default     = ""
}

variable "cdc_start_time" {
  description = "The Unix timestamp integer for the start of the Change Data Capture (CDC) operation."
  type        = number
  default     = null
}

variable "replication_instance_arn" {
  description = "The Amazon Resource Name (ARN) of the replication instance."
  type        = string
  default     = ""
}

variable "migration_type" {
  description = "The migration type."
  type        = string
  default     = ""
}

variable "replication_task_settings" {
  description = "An escaped JSON string that contains the task settings."
  type        = string
  default     = ""
}

variable "source_endpoint_arn" {
  description = "The Amazon Resource Name (ARN) string that uniquely identifies the source endpoint."
  type        = string
  default     = ""
}

variable "target_endpoint_arn" {
  description = "The Amazon Resource Name (ARN) string that uniquely identifies the target endpoint."
  type        = string
  default     = ""
}

variable "table_mappings" {
  description = "An escaped JSON string that contains the table mappings."
  type        = string
  default     = ""
}

variable "replication_task_name" {
  description = "Name of replication task"
  type        = string
  default     = ""
}


#Event subscription variables

variable "event_categories" {
  description = "List of event categories to listen for"
  type        = list
  default     = []
}

variable "sns_topic_arn" {
  description = "sns topic arn"
  type        = string
  default     = ""
}

variable "source_type" {
  description = "Type of source for events. Valid values: replication-instance or replication-task"
  type        = string
  default     = ""
}

variable "source_ids" {
  description = "Ids of sources to listen to."
  type        = list
  default     = []
}

variable "certificate_pem" {
  description = "The contents of the .pem X.509 certificate file for the certificate."
  type        = string
  default     = ""
}

variable "event_subscription" {
  description = "Name of event subscription"
  type        = string
  default     = ""
}
