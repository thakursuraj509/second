output "replication_instance_arn" {
  value = concat(aws_dms_replication_instance.ta_replication_instance.*.replication_instance_arn, [""])[0]
}

output "source_endpoint_arn" {
  value = concat(aws_dms_endpoint.ta_source_endpoint.*.endpoint_arn, [""])[0]
}

output "target_endpoint_arn" {
  value = concat(aws_dms_endpoint.ta_target_endpoint.*.endpoint_arn, [""])[0]
}

output "certificate_arn" {
  value = concat(aws_dms_certificate.dms_certificate.*.certificate_arn, [""])[0]
}

output "replication_task_arn" {
  value = concat(aws_dms_replication_task.ta_replication_task.*.replication_task_arn, [""])[0]
}