# --- DynamoDB Database ---
module "database" {
  source = "./modules/terraform-aws-dynamodb"

  # Core Table Settings from the Object
  name         = var.database_config.name
  billing_mode = var.database_config.billing_mode
  hash_key     = var.database_config.hash_key
  range_key    = var.database_config.range_key

  # Type settings (using the defaults from the object if not provided)
  hash_key_type  = var.database_config.hash_key_type
  range_key_type = var.database_config.range_key_type

  # Schema & Indexing
  attributes               = var.database_config.attributes
  global_secondary_indexes = var.database_config.global_secondary_indexes

  tags       = merge(var.tags, { Component = "Database" })
  depends_on = [module.vpc]
}

# --- Ingest Lambda ---
module "ingest_lambda" {
  source                 = "./modules/terraform-aws-lambda"
  function_name          = "ingest-log-service"
  handler                = var.lambda_config["ingest"].handler
  runtime                = var.lambda_config["ingest"].runtime
  architectures          = var.lambda_config["ingest"].architectures
  memory_size            = var.lambda_config["ingest"].memory_size
  timeout                = var.lambda_config["ingest"].timeout
  enable_cloudwatch_logs = true


  function_url_config = {
    auth_type = var.lambda_config["ingest"].function_url_config.auth_type
    enabled   = var.lambda_config["ingest"].function_url_config.enabled
  }

  custom_policies = [
    {
      name = "DynamoDBWriteAccess"
      statements = [
        {
          effect = "Allow"
          actions = [
            "dynamodb:PutItem",
          ]
          resources = [module.database.table_arn]
        },

        {
          effect  = "Deny"
          actions = ["dynamodb:*"]
          resources = [
            module.database.table_arn,
            "${module.database.table_arn}/index/*"
          ]
          condition = {
            StringNotEquals = {
              "aws:SourceVpce" = [aws_vpc_endpoint.dynamodb.id]
            }
          }
        }
      ]
    }
  ]
  deployment_package = {
    bucket = aws_s3_bucket.artifacts.bucket
    key    = var.lambda_config["ingest"].s3_key
  }

  vpc_config = {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.log_service_sg.id]
  }

  environment_variables = {
    TABLE_NAME        = module.database.table_name
    GSI_PARTITION_KEY = local.log_group_name
  }

  tags = var.tags

  depends_on = [module.database]
}

# --- Read Lambda ---
module "read_lambda" {
  source                 = "./modules/terraform-aws-lambda"
  function_name          = "read-recent-log-service"
  handler                = var.lambda_config["read"].handler
  runtime                = var.lambda_config["read"].runtime
  architectures          = var.lambda_config["read"].architectures
  memory_size            = var.lambda_config["read"].memory_size
  timeout                = var.lambda_config["read"].timeout
  enable_cloudwatch_logs = true
  function_url_config = {
    auth_type = var.lambda_config["read"].function_url_config.auth_type
    enabled   = var.lambda_config["read"].function_url_config.enabled
  }

  custom_policies = [
    {
      name = "DynamoDBReadAccess"
      statements = [
        {
          effect  = "Allow"
          actions = ["dynamodb:Query"]
          resources = [
            module.database.table_arn,
            "${module.database.table_arn}/index/*"
          ]
          condition = {}
        },
        {
          effect  = "Deny"
          actions = ["dynamodb:*"]
          resources = [
            module.database.table_arn,
            "${module.database.table_arn}/index/*"
          ]
          condition = {
            StringNotEquals = {
              "aws:SourceVpce" = [aws_vpc_endpoint.dynamodb.id]
            }
          }
        }
      ]
    }
  ]

  deployment_package = {
    bucket = aws_s3_bucket.artifacts.bucket
    key    = var.lambda_config["read"].s3_key

  }

  vpc_config = {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.log_service_sg.id]
  }

  environment_variables = {
    TABLE_NAME        = module.database.table_name
    GSI_NAME          = var.database_config.global_secondary_indexes[0].name
    GSI_PARTITION_KEY = local.log_group_name
  }
  tags = var.tags

  depends_on = [module.database]
}
