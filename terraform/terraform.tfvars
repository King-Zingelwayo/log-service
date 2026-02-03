
region      = "eu-west-1"
application = "log-service"
environment = "dev"
tags = {
  "recruiter" : "gamesglobal"
  "owner" : "sihle ndlovu"
  "email" : "ndlovu.code@outlook.com"
  "phone" : "0839578644"
  "environment" : "dev"
}
database_config = {
  name      = "LogServiceTable"
  hash_key  = "ID"
  range_key = "DateTime"

  # Attributes required for the GSI to work
  attributes = {
    "ID"              = "S"
    "GSIPartitionKey" = "S"
    "DateTime"        = "S"
  }

  global_secondary_indexes = [
    {
      name            = "RecentLogsIndex"
      hash_key        = "GSIPartitionKey"
      range_key       = "DateTime"
      projection_type = "ALL"
    }
  ]

  point_in_time_recovery = true
}


lambda_config = {
  ingest = {
    handler       = "bootstrap"
    runtime       = "provided.al2023"
    architectures = ["arm64"]
    s3_key        = "ingest.zip"

    function_url_config = {
      enabled   = true
      auth_type = "NONE"
    }
  }
  read = {
    enable_function_url = true
    handler             = "bootstrap"
    architectures       = ["arm64"]
    runtime             = "provided.al2023"
    s3_key              = "read-recent.zip"

    function_url_config = {
      enabled   = true
      auth_type = "NONE"
    }
  }
}
