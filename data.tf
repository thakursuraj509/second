data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.specific_vpc != "" ? var.specific_vpc : var.environment_full[upper(var.environment)]]
  }
}
data "aws_subnets" "private_subnet_ids" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  tags = {
    Type       = "Private"
    PrimaryUse = "General"
  }
}

data "aws_security_group" "AWS_Public_Services" {
  filter {
    name   = "tag:AllowedUse"
    values = ["AWSPublicServices"]
  }
}

data "aws_security_group" "AWS_CloudWatchLogs" {
  filter {
    name   = "tag:AllowedUse"
    values = ["CloudWatch"]
  }
}

data "aws_security_group" "Internal" {
  filter {
    name   = "tag:AllowedUse"
    values = ["Internal"]
  }
}
