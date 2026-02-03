output "function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "function_invoke_arn" {
  description = "The invoke ARN of the Lambda function (useful for API Gateway permissions)"
  value       = aws_lambda_function.this.invoke_arn
}

output "role_arn" {
  description = "The IAM role ARN associated with the Lambda function"
  value       = aws_iam_role.lambda_role.arn
}

output "role_name" {
  description = "The IAM role name associated with the Lambda function"
  value       = aws_iam_role.lambda_role.name
}

output "log_group_name" {
  description = "The CloudWatch Log Group for the Lambda function"
  value       = aws_cloudwatch_log_group.lambda[*].name
}

output "s3_bucket" {
  description = "The S3 bucket where the Lambda code resides"
  value       = var.deployment_package.bucket
}

output "s3_key" {
  description = "The S3 key for the Lambda code zip"
  value       = var.deployment_package.key
}

output "function_url" {
  value = try(aws_lambda_function_url.this[0].function_url, "")
}