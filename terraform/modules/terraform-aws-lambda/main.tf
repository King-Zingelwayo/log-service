resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_role.arn
  architectures = var.architectures
  runtime       = var.runtime
  handler       = var.handler
  timeout       = var.timeout
  memory_size   = var.memory_size

  s3_bucket         = var.deployment_package.bucket
  s3_key            = var.deployment_package.key
  s3_object_version = var.deployment_package.version

  environment {
    variables = var.environment_variables
  }

  tracing_config {
    mode = var.enable_xray_tracing ? "Active" : "PassThrough"
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []

    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  tags = var.tags
}

resource "aws_lambda_function_url" "this" {
  count              = var.function_url_config.enabled ? 1 : 0
  function_name      = aws_lambda_function.this.function_name
  authorization_type = var.function_url_config.auth_type

  cors {
    allow_origins = ["*"]
    allow_methods = ["POST", "GET"]
    allow_headers = ["content-type"]
  }
}

resource "aws_lambda_permission" "allow_url_invocation" {
  statement_id           = "AllowFunctionURL"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.this.function_name
  principal              = "*"
  function_url_auth_type = var.function_url_config.auth_type
}


resource "aws_lambda_permission" "allow_lambda_invocation" {
  statement_id  = "AllowLambdaInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "*"
}

