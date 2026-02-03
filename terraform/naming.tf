locals {
  vpc_name               = "${var.environment}-${var.application}-vpc"
  vpc_tag_name           = local.vpc_name
  vpc_cidr               = "10.0.0.0/16"
  azs                    = ["eu-west-1a", "eu-west-1b"]
  subnets                = ["10.0.1.0/24", "10.0.2.0/24"]
  endpoint_type          = "Gateway"
  bucket_name            = "log-service-artifacts-${random_id.bucket_suffix.hex}"
  log_group_name         = "ALL_LOGS"
  enable_cloudwatch_logs = true
  enable_xray_tracing    = false
}
